require 'ctm/ms_sql_view'
module Master
  class Residence < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView

    # relations
    belongs_to :loan, class_name: 'Master::Loan'

    from '_RESIDENCE', as: 'residence'

    field :id,                  column: '_RESIDENCE_id'
    field :loan_id,             column: 'loanGeneral_Id'
    field :borrower_id,         column: 'BorrowerID'
    field :address,             column: '_StreetAddress'
    field :city,                column: '_City'
    field :state,               column: '_State'
    field :postal_code,         column: '_PostalCode'
    field :country,             column: '_Country'

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
