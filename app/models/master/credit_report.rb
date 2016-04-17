require 'ctm/ms_sql_view'
module Master
  class CreditReport < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView

    # relations
    belongs_to :loan, class_name: 'Master::Loan', inverse_of: :reo_property

    from 'CREDIT_REPORT', as: 'cr'

    field :id,                      column: 'CREDIT_REPORT_id'
    field :loan_id,                 column: 'loanGeneral_Id'
    field :borrower_position
    field :borrower_names
    field :report_type
    field :order_date
    field :order_status
    field :credit_report_identifier
    field :engine_code
    field :credit_agency
    field :repository_type
    field :credit_report_first_issued_date

    alias_attribute :loan_general_id, :loan_id

    # TODO: Figure out how to make it so we don't need to declare this
    # in each model and just keep it in the parent module.
    def self.sqlserver_create_view
      self.build_query
    end
  end
end
