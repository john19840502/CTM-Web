require 'ctm/ms_sql_view'
module Master
  module Person
    class Race < Master::Avista::ReadOnly
      extend ::CTM::MSSqlView

      # relations
      belongs_to :borrower, class_name: 'Master::Person::Borrower'


      from 'HMDA_RACE', as: 'race'

      field :id,                  column: 'HMDA_RACE_id'
      field :race_type,           column: '_Type'
      field :borrower_id,         column: 'BORROWER_id', source: 'borrower'

      join 'BORROWER',            on: 'loanGeneral_Id', and: 'BorrowerID',  as: 'borrower', type: :inner

      def self.sqlserver_create_view
        self.build_query
      end

      def to_s
        race_type.to_s
      end
    end
  end
end