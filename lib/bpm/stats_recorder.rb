
module Bpm
  class StatsRecorder

    def create_new_event loan, user, validation_type
      event = Bpm::LoanValidationEvent.new({validation_type: validation_type, loan_num: loan.loan_num}, without_protection: true)
      if user
        event.validated_by_id = user.uuid
        event.validated_by = "#{user.first_name} #{user.last_name}"
      end
      collect_loan_status(event, loan)
      event.save!
      event
    end

    def record_validation_event flow, event_id, validation_results, fact_types_sent
      event = Bpm::LoanValidationEvent.find(event_id.to_i)
      flow_event = create_flow_event(flow, event, validation_results, fact_types_sent)
      flow_event.save!
    end

    def record_underwriter_validation_event results, event_id
      event = Bpm::LoanValidationEvent.find(event_id.to_i)
      event.validation_status = determine_status(event, results[:errors], results[:warnings])
      event.loan_validation_flows << make_fake_flow_for_underwriter_validation(results)
      event.save!
    end

    def make_fake_flow_for_underwriter_validation results
      Bpm::LoanValidationFlow.new.tap do |flow|
        flow.name = "uw validation"
        flow.conclusion = results[:errors].any? ? "Not Acceptable" : "Acceptable"

        results[:errors].each do |err|
          flow.loan_validation_event_messages << collect_message('error', err)
        end

        results[:warnings].each do |err|
          flow.loan_validation_event_messages << collect_message('warning', err)
        end
      end
    end

    def determine_status event, errors, warnings
      uncleared = ->(message) do
        latest_event = message[:history].first
        latest_event.nil? || latest_event[:action] != 'Cleared'
      end

      return 'FAIL' if event.validation_status == "FAIL" || errors.any?(&uncleared)
      return 'REVIEW' if warnings.any?(&uncleared)
      event.validation_status
    end

    def create_flow_event(flow, event, validation_results, fact_types_sent)
    
      #  To calculate the validation status for the decisonator rules
      if event.validation_status != 'FAIL'
        if !validation_results[:errors].empty?
          event.validation_status = 'FAIL'
        elsif !validation_results[:warnings].empty?
          validation_flag = false
          validation_results[:warnings].each do |warning|
            validation_flag = true if warning[2]
          end
          event.validation_status = 'REVIEW' unless validation_flag
        end    
      end

      event_flow = collect_flow_info(flow, validation_results, fact_types_sent)
      event.loan_validation_flows << event_flow
      event
    end

    private

    def find_underwriters(loan)
      ass = loan.loan_general.loan_assignees || []
      ass.select { |a| a.role == 'Underwriter' }.map do |a|
        a.first_name + ' ' + a.last_name
      end
    end

    def collect_loan_status(event, loan)
      event.loan_num = loan.loan_num
      underwriters = find_underwriters(loan)
      event.underwriter = underwriters.any? ? underwriters.join(', ') : 'n/a'
      event.product_code = loan.product_code
      event.channel = loan.channel
      event.property_state = loan.loan_general.property_state
      event.loan_status = loan.loan_status
      event.pipeline_lock_status = loan.loan_general.try(:additional_loan_datum).try(:pipeline_lock_status_description)
    end

    def collect_flow_info(flow, validation_results, fact_types_sent)
      fl = Bpm::LoanValidationFlow.new
      fl.name = flow
      fl.conclusion = validation_results.nil? ? 'Acceptable' : validation_results[:conclusion]
      
      fl.loan_validation_event_messages << error_messages(validation_results, fl)
      fl.loan_validation_event_messages << warnings(validation_results)

      fl.loan_validation_fact_type_values << collect_fact_types(fact_types_sent, fl) unless fact_types_sent.empty?
      fl
    end

    def error_messages(validation_results, flow)
      Array(validation_results[:errors]).map do |message|
        flow.conclusion = 'Not Acceptable'
        collect_message('error', message)
      end
    end

    def warnings(validation_results)
      Array(validation_results[:warnings]).map do |message|
        collect_message('warning', message[:text])
      end
    end

    def collect_message(message_type, message)
      message = message[:text] unless message.is_a? String
      msg_type = Bpm::LoanValidationMessageType.where(message_type: message_type, name: message).last
      
      unless msg_type
        msg_type = Bpm::LoanValidationMessageType.new
        msg_type.message_type = message_type
        msg_type.name = message
        msg_type.save!
      end

      mr = Bpm::LoanValidationEventMessage.new()
      mr.loan_validation_message_type = msg_type
      mr
    end

    def collect_fact_types(fact_types, flow)
      ftvs = []
      fact_types.each do |k, v| 
        ft = Bpm::LoanValidationFactType.where(name: k).last
        unless ft
          ft = Bpm::LoanValidationFactType.new
          ft.name = k
          ft.save!
        end

        fv = Bpm::LoanValidationFactTypeValue.new
        fv.loan_validation_flow = flow
        fv.loan_validation_fact_type = ft
        fv.fact_value = v
        fv.save!
        ftvs << fv
      end
      ftvs
    end
  end
end
