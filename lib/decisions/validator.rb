module Decisions
  class Validator
    attr_accessor :response, :flows

     # Fetching all the flows defined for the validations

    def initialize(validation_type, loan)
      @result = []
      @validation_type = validation_type
      @loan = loan
      @event = nil
      @response = nil
      @flows = extract_flows(@validation_type)
    end

    def extract_flows(validation_type)
      arr = []
      
      @validations_queue = [ 'initial_disclosure', 'registration', 'underwriter', 'preclosing', 'closing']
      @index = @validations_queue.index(validation_type) 
      @validations_queue = @validations_queue.slice!(0..@index) # This removes the validation types which are not required to check against. For validation type underwriter, the queue will contain ['initial_disclosue', 'registration', 'underwriter']
      
      Decisions::Flow::FLOWS.each do |key, val|
        if val[:validate].in?(@validations_queue) && !validation_type.in?(val[:except]) # Do not include the flow if it is excepted in validation type
          arr << key.to_s
        end
      end
      arr
    end

    def execute
      @event = Bpm::StatsRecorder.new.create_new_event(@loan, nil, @validation_type)
      @flows.each do |flow|
        @result << execute_validation(@validation_type, flow, @loan, @event.id)
      end
      case @validation_type
        when 'underwriter'
          @result = Validation::Underwriter::do_checks(@loan, nil) # current_user is nil bacause it is from daily run jobs
          Bpm::StatsRecorder.new.record_underwriter_validation_event(@result, @event.id)
      end
      @result
    end

    def execute_validation(validation_type, flow, loan, event_id)
      fact_types = Decisions::Facttype.new(flow, {loan: loan, event_id: event_id}).execute
      @response  = Decisions::Flow.new(flow, fact_types).execute
      
      @response[:warnings].each do |message|
        # if validation_alert = ValidationAlert.find_by_loan_id_and_rule_id_and_alert_type(loan.id, message[0], validation_type)
        if validation_alert = ValidationAlert.where(loan_id: loan.id, rule_id: message[0]).first
          message << validation_alert.as_json.merge({:user_name => validation_alert.user_name})
        end
      end

      Bpm::StatsRecorder.new.record_validation_event(flow, @event.id, @response, fact_types)
      @response
    end

    def fetch_warning_messages
      @loan.errors[:warning].each do |message|
        # if validation_alert = ValidationAlert.find_by_loan_id_and_rule_id_and_alert_type(@loan.id, message[0], @validation_type)
        if validation_alert = ValidationAlert.where(loan_id: @loan.id, rule_id: message[0]).first
          message << validation_alert.as_json.merge({:user_name => validation_alert.user_name})
        end
      end
      @loan.errors
    end

    def self.validate_loans
      loans_validated = Bpm::LoanValidationEvent.where(validated_by_id: nil).where('created_at > ?', Time.now.beginning_of_day).map(&:loan_num)
      @registration_loans = Loan.ready_for_registration_validation_multi_step
      @registration_loans.each do |loan|
        @result = new('registration', loan).execute unless loan.loan_num.in?(loans_validated)
      end

      @underwriter_loans = Loan.uw_loans_ready_for_validation
      @underwriter_loans.each do |loan|
        @result = new('underwriter', loan).execute unless loan.loan_num.in?(loans_validated)
      end
    end

  end
end
