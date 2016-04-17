class Master::LoanDetails::CustomLoanData < ActiveRecord::Base
  
  VALID_CONSENT_ACTIONS = ["No consent received", "Consent imaged"]

  # because rails is being dumb
  self.table_name = "ctmweb_master_loan_details_custom_loan_data_#{Rails.env.downcase}"

  belongs_to :loan, class_name: 'Master::Loan', foreign_key: :loan_num, primary_key: :loan_num
  # used to add columns for a loan so we can add differnet fields that are required for our
  # processing. For example: force_boarding so we can mark this loan for boarding outside of 
  # normal methods.

  validates :consent_action,
    :inclusion => { :in => VALID_CONSENT_ACTIONS,
                    :message => "must be one of #{VALID_CONSENT_ACTIONS.join(', ')}" },
    :allow_nil => true
  validate :consent_fields_must_be_set_together

  def self.completed_consent_ids
    where(:consent_complete => true).pluck(:loan_num)
  end

  def valid_consent_actions
    VALID_CONSENT_ACTIONS
  end

  private

  def consent_fields_must_be_set_together
    errors.add(:base, 'Incomplete ESign consents may not have a consent action') if !consent_complete? && !consent_action.nil?
    errors.add(:base, 'Completed ESign consents must have a consent action') if consent_complete? && consent_action.nil?
  end

end
