require 'ctm/ms_sql_view'
module Master
  class Employer < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView

    # relations
    belongs_to :loan, class_name: 'Master::Loan'

    from 'EMPLOYER', as: 'employer'

    field :id,                  column: 'EMPLOYER_id'
    field :loan_id,             column: 'loanGeneral_Id'
    field :phone_num,           column: '_TelephoneNumber'
    field :borrower_id,         column: 'BorrowerID'
    field :name,                column: '_Name'
    field :position,            column: 'EmploymentPositionDescription'
    field :years_at_position,   column: 'CurrentEmploymentYearsOnJob'
    field :months_at_position,  column: 'CurrentEmploymentMonthsOnJob'
    field :years_in_profession, column: 'CurrentEmploymentTimeInLineOfWorkYears'
    field :self_employment_flag, column: 'EmploymentBorrowerSelfEmployedIndicator'

    alias_attribute :loan_general_id, :loan_id

    # scopes
    scope :primary,   where(:borrower_id => 'BRW1')
    scope :secondary, where(:borrower_id => 'BRW2')


    # TODO: Figure out how to make it so we don't need to declare this
    # in each model and just keep it in the parent module.
    def self.sqlserver_create_view
      self.build_query
    end

  end
end
