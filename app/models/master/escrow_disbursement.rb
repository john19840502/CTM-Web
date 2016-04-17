require 'ctm/ms_sql_view'
module Master
  class EscrowDisbursement < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView

    # relations
    belongs_to :loan, class_name: 'Master::Loan', inverse_of: :escrow_disbursements

    from 'DISBURSEMENT_PAYMENT', as: 'dp'

    field :id,                  column: 'DISBURSEMENT_PAYMENT_id'
    field :loan_id,             column: 'loanGeneral_Id'
    field :reference_id,        column: 'Reference_ID'
    field :payment_scheduled_on, column: 'PaymentScheduledDate'
    field :payment_amount,      column: 'PaymentAmount'

    alias_attribute :loan_general_id, :loan_id

    # TODO: Figure out how to make it so we don't need to declare this
    # in each model and just keep it in the parent module.
    def self.sqlserver_create_view
      self.build_query
    end

    def escrow_disbursement_type
      loan.escrow_disbursement_types.find { |edt| edt.reference_id == self.reference_id }
    end

    delegate :disbursement_type, to: :escrow_disbursement_type, allow_nil: true
  end
end
