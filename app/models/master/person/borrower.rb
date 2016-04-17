require 'ctm/ms_sql_view'
module Master
  module Person
    class Borrower < Master::Avista::ReadOnly
      extend ::CTM::MSSqlView

      # relations
      belongs_to :loan, class_name: 'Master::Loan'
      has_many :races, class_name: 'Master::Person::Race'


      from 'BORROWER', as: 'borrower'

      field :id,                        column: 'BORROWER_id'
      field :loan_id,                   column: 'loanGeneral_Id',               source: 'borrower'
      field :first_name,                column: '_FirstName'
      field :last_name,                 column: '_LastName'
      field :ssn,                       column: '_SSN'
      field :middle_name,               column: '_MiddleName'
      field :suffix,                    column: '_NameSuffix'
      field :home_phone_num,            column: '_HomeTelephoneNumber'
      field :cell_phone_num,            column: '_CellTelephoneNumber'
      field :borrower_id,               column: 'BorrowerID'
      field :email,                     column: '_EmailAddress'
      field :age_at_application,        column: '_AgeAtApplicationYears'
      field :marital_status,            column: 'MaritalStatusType'
      field :birth_date,                column: '_BirthDate'
      field :schooling_years,           column: 'SchoolingYears'
      field :credit_score,              column: 'CreditScore'
      field :equifax_credit_score
      field :experian_credit_score
      field :trans_union_credit_score
      field :gender_type,               column: 'GenderType',                   source: 'GMON'
      field :hmda_ethnicity_type,       column: 'HMDAEthnicityType',            source: 'GMON'
      field :citizenship_type,          column: 'CitizenshipResidencyType',     source: 'DECL'
      field :intent_to_occupy_type,     column: 'IntentToOccupyType',           source: 'DECL'
      field :ssn,                       column: '_SSN'
      field :application_signed_on,     column: '_ApplicationSignedDate'

      join 'LOAN_GENERAL',            on: 'loanGeneral_Id',                     as: 'LG',   type: :inner
      join 'GOVERNMENT_MONITORING',   on: 'loanGeneral_Id', and: 'BorrowerID',  as: 'GMON', type: :left_outer
      join 'DECLARATION',             on: 'loanGeneral_Id', and: 'BorrowerID',  as: 'DECL', type: :left_outer

      alias_attribute :loan_general_id, :loan_id
      alias_attribute :marital_status_type, :marital_status

      # borrowers are coming back with multiple rows, narrowing them down
      # here so we have just what we need.
      def self.primary
        order(:borrower_id).uniq(&:borrower_id).first
      end

      def self.secondary
        order(:borrower_id).uniq(&:borrower_id)[1]
      end

      def self.coborrowers
        order(:borrower_id).uniq(&:borrower_id)[2, self.count-1]
      end

      def self.by_position(position)
        where(borrower_id: "BRW#{position}").first
      end

      def get_index
        borrower_id[3].to_i
      end

      # TODO: Figure out how to make it so we don't need to declare this
      # in each model and just keep it in the parent module.
      def self.sqlserver_create_view
        self.build_query
      end

      def hmda_race_type
        races.first.try(:race_type)
      end

      def mail_to
        Master::MailTo.where(borrower_id: borrower_id, loan_id: loan_id).first
      end

      def income_sources
        loan.income_sources.where(borrower_id: borrower_id)
      end

      def qualifying_income
        income_sources.inject(0.0){|sum, i| sum + i.monthly_amount.to_f}
      end

      def employer
        loan.employers.where(borrower_id: borrower_id).first
      end

      def residence
        loan.residences.where(borrower_id: borrower_id).first
      end

      def full_name separator = ' '
        [first_name, middle_name, last_name, suffix].map(&:presence).compact.join(separator)
      end

      def is_us_citizen?
        citizenship_type == 'USCitizen'
      end

      def is_permanent_resident?
        [ "USCitizen", "PermanentResidentAlien" ].include? citizenship_type
      end

      def middle_credit_score
        scores = [equifax_credit_score, experian_credit_score, trans_union_credit_score].map(&:presence).compact.sort
        case scores.size
        when 3; scores[1]
        when 2; scores[0]
        when 1; scores[0]
        end
      end

      def middle_credit_score_source
        return unless middle_credit_score
        {
            'equifax' => equifax_credit_score,
            'experian' => experian_credit_score,
            'transunion' => trans_union_credit_score
        }.key(middle_credit_score)
      end

      def dup_ssn?
        Borrower.where(ssn: ssn).count > 1
      end

      def credit_reports
        index = get_index.to_s
        loan.credit_reports.select{|cr| cr.borrower_position.include?(index) }
      end
    end
  end
end
