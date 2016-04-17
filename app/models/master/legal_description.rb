require 'ctm/ms_sql_view'
module Master
  class LegalDescription < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView

    from '_LEGAL_DESCRIPTION', as: 'ld'

    # relations
    belongs_to :loan, class_name: 'Master::Loan', inverse_of: :legal_descriptions

    # fields
    field :loan_id,                 column: 'loanGeneral_id'
    field :text,                    column: '_TextDescription'
    field :description_type,        column: '_Type'


    # # used to build out the view for datamart.
    def self.sqlserver_create_view
      self.build_query
    end
  end
end
