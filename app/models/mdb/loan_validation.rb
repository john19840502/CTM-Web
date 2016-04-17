module Mdb
  class LoanValidation
    include Mongoid::Document
    include Mongoid::Timestamps

    field :loan_num, type: String
    field :underwriter, type: String
    field :product_code, type: String
    field :channel, type: String
    field :state, type: String

    embeds_many :loan_validation_events, class_name: 'Mdb::LoanValidationEvent'

#    attr_accessible :loan_num, :underwriter, :product_code, :channel, :state, :created_at, :updated_at, :loan_validation_events

    accepts_nested_attributes_for :loan_validation_events, allow_destroy: true, reject_if: :all_blank

    validates :loan_num, presence: true

    def self.add_validation_info loan, user, validation_type, total_rools_applied

      username = user ? "#{user.first_name} #{user.last_name}" : 0
      user_id = user.id if user

      uw = loan.loan_general.loan_assignees.empty? ? 
        'n/a' : 
        loan.loan_general.loan_assignees.map{|ass| "#{ass.first_name} #{ass.last_name}" if ass.role.eql?("Underwriter") }.compact.join

      lv = where(loan_num: loan.loan_num).first
      lv = new(loan_num: loan.loan_num) unless lv

      lv.underwriter = uw unless lv.underwriter.eql?(uw)
      lv.product_code = loan.product_code unless lv.product_code.eql?(loan.product_code)
      lv.channel = loan.channel unless lv.channel.eql?(loan.channel)
      lv.state = loan.property_state unless lv.state.eql?(loan.property_state)

      lve = lv.loan_validation_events.where(user_id: user_id).first

      unless lve
        lve = Mdb::LoanValidationEvent.new(
          username: username, 
          user_id: user_id
        )
        lv.loan_validation_events << lve 
      end

      details = lve.loan_validation_event_details.where(validation_type: validation_type,
              status: loan.loan_status,
              pipeline_status: loan.loan_general.try(:additional_loan_datum).try(:pipeline_lock_status_description),
              error_base_messages_hash: Mdb::LoanValidationEventDetail.get_hash_value(loan.errors[:base]),
              error_warning_messages_hash: Mdb::LoanValidationEventDetail.get_hash_value(loan.errors[:warning])).first

      if details
        details.total_attempts += 1
        details.dates << Time.now
      else
        lve.loan_validation_event_details << Mdb::LoanValidationEventDetail.new(total_attempts: 1,
          dates: [Time.now],
          validation_type: validation_type,
          total_rools_applied: total_rools_applied,
          status: loan.loan_status,
          pipeline_status: loan.loan_general.try(:additional_loan_datum).try(:pipeline_lock_status_description),
          error_base_messages: loan.errors[:base],
          error_base_messages_hash: Mdb::LoanValidationEventDetail.get_hash_value(loan.errors[:base]),
          error_warning_messages: loan.errors[:warning],
          error_warning_messages_hash: Mdb::LoanValidationEventDetail.get_hash_value(loan.errors[:warning])
        )
      end

      lv.save!
    end
  end
end
