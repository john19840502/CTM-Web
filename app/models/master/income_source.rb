require 'ctm/ms_sql_view'
module Master
  class IncomeSource < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView
    attr_accessible :monthly_amount, :borrower_id, :income_type

    # relations
    belongs_to :loan, class_name: 'Master::Loan', inverse_of: :income_sources

    from 'CURRENT_INCOME', as: 'ci'

    field :id,                  column: 'CURRENT_INCOME_id'
    field :loan_id,             column: 'loanGeneral_Id'
    field :borrower_id,         column: 'BorrowerID'
    field :income_type,         column: 'IncomeType'
    field :monthly_amount,      column: '_MonthlyTotalAmount'

    alias_attribute :loan_general_id, :loan_id

    # TODO: Figure out how to make it so we don't need to declare this
    # in each model and just keep it in the parent module.
    def self.sqlserver_create_view
      self.build_query
    end

  end
end
