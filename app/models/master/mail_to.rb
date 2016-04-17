require 'ctm/ms_sql_view'
module Master
  class MailTo < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView

    from '_MAIL_TO', as: 'MT'
    belongs_to :loan, class_name: 'Master::Loan'

    field :id,                  column: '_MAIL_TO_id'
    field :loan_id,             column: 'loanGeneral_Id'
    field :borrower_id,         column: 'BorrowerID'
    field :street_address,      column: '_StreetAddress'
    field :street_address_2,    column: '_StreetAddress2'
    field :city,                column: '_City'
    field :state,               column: '_State'
    field :postal_code,         column: '_PostalCode'
    field :country,             column: '_Country'


    # TODO: Figure out how to make it so we don't need to declare this
    # in each model and just keep it in the parent module.
    def self.sqlserver_create_view
      self.build_query
    end

    def full_address
      [street_address, street_address_2].join(' ')
    end

  end
end