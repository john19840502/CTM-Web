require 'ctm/ms_sql_view'
module Master
  class PaymentOccurrence < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView
    #attr_accessible :amount, :down_payment_type

    # relations
    belongs_to :loan, class_name: 'Master::Loan', inverse_of: :payment_occurrences

    from 'PAYMENT_OCCURRENCE', as: 'po'

    field :id,                  column: 'PAYMENT_OCCURRENCE_id'
    field :loan_id,             column: 'loanGeneral_Id'
    field :payment_received_on, column: 'PaymentReceivedDate'
    field :payment_number,      column: 'PaymentNumber'

    alias_attribute :loan_general_id, :loan_id

    # TODO: Figure out how to make it so we don't need to declare this
    # in each model and just keep it in the parent module.
    def self.sqlserver_create_view
      self.build_query
    end

  end
end
