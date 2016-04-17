require 'ctm/ms_sql_view'
module Master
  module LoanDetails
    class Calculation < Master::Avista::ReadOnly
      extend ::CTM::MSSqlView

      from 'CALCULATION', as: 'calculation'

      belongs_to :loan, class_name: 'Master::Loan'

      field :id,                  column: 'CALCULATION_id'
      field :loan_id,             column: 'loanGeneral_Id',         source: 'calculation'
      field :name,                column: '_Name'
      field :value,               column: '_Value'
      field :borrower_id,         column: 'BorrowerID'
      field :section,             column: 'Section'

      def self.total_obligation_ratio
        where(name: 'TotalObligationsIncomeRatio').sum(:value)
      end

      def self.total_monthly_payments
        where(name: 'TotalAllMonthlyPayment').sum(:value)
      end

      def self.total_monthly_income
        where(name: 'TotalMonthlyIncome').sum(:value)
      end


      def self.sqlserver_create_view
        self.build_query
      end
    end
  end
end