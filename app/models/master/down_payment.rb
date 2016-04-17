require 'ctm/ms_sql_view'
module Master
  class DownPayment < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView
    attr_accessible :amount, :down_payment_type

    # relations
    belongs_to :loan, class_name: 'Master::Loan', inverse_of: :down_payments

    from 'DOWN_PAYMENT', as: 'dp'

    field :id,                  column: 'DOWN_PAYMENT_id'
    field :loan_id,             column: 'loanGeneral_Id'
    field :amount,              column: '_Amount'
    field :down_payment_type,   column: '_Type'
    field :source_description,  column: '_SourceDescription'

    alias_attribute :loan_general_id, :loan_id

    # TODO: Figure out how to make it so we don't need to declare this
    # in each model and just keep it in the parent module.
    def self.sqlserver_create_view
      self.build_query
    end

  end
end
