require 'ctm/ms_sql_view'
module Master
  class Asset < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView
    attr_accessible :amount, :asset_type

    # relations
    belongs_to :loan, class_name: 'Master::Loan'

    from 'ASSET', as: 'asset'

    field :loan_id,             column: 'loanGeneral_Id'
    field :borrower_id,         column: 'BorrowerID'
    field :asset_type,          column: '_Type'
    field :cash_or_market_value_amount, column: '_CashOrMarketValueAmount'

    alias_attribute :loan_general_id, :loan_id
    alias_attribute :amount, :cash_or_market_value_amount

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
