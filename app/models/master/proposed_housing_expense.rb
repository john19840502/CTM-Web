require 'ctm/ms_sql_view'
module Master
  class ProposedHousingExpense < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView
    attr_accessible :payment_amount, :housing_expense_type

    # relations
    belongs_to :loan, class_name: 'Master::Loan', inverse_of: :proposed_housing_expenses

    from 'PROPOSED_HOUSING_EXPENSE', as: 'phe'

    field :id,                  column: 'PROPOSED_HOUSING_EXPENSE_id'
    field :loan_id,             column: 'loanGeneral_Id'
    field :housing_expense_type, column: 'HousingExpenseType'
    field :payment_amount,      column: '_PaymentAmount'

    alias_attribute :loan_general_id, :loan_id

    # TODO: Figure out how to make it so we don't need to declare this
    # in each model and just keep it in the parent module.
    def self.sqlserver_create_view
      self.build_query
    end

  end
end
