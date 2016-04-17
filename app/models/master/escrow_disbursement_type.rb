require 'ctm/ms_sql_view'
module Master
  class EscrowDisbursementType < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView

    # relations
    belongs_to :loan, class_name: 'Master::Loan', inverse_of: :escrow_disbursement_types

    from 'DISBURSEMENT_EVENT', as: 'de'

    field :id,                  column: 'DISBURSEMENT_EVENT_id'
    field :loan_id,             column: 'loanGeneral_Id'
    field :reference_id,        column: 'Reference_ID'
    field :disbursement_type,   column: 'DisbursementItemType'
    field :frequency,           column: 'PaymentFrequencyType'
    field :annual_payment_amount, column: 'AnnualPaymentAmount'

    alias_attribute :loan_general_id, :loan_id

    # TODO: Figure out how to make it so we don't need to declare this
    # in each model and just keep it in the parent module.
    def self.sqlserver_create_view
      self.build_query
    end

    def disbursements
      loan.escrow_disbursements.select { |ed| ed.reference_id == self.reference_id }
    end
  end
end
