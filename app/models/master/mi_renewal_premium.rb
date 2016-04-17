require 'ctm/ms_sql_view'
module Master
  class MiRenewalPremium < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView
    #attr_accessible :liability_type, :holder_name, :lien_position, :monthly_payment_amount

    # relations
    belongs_to :loan, class_name: 'Master::Loan'

    from 'MI_RENEWAL_PREMIUM', as: 'premium'

    field :liability_id,        column: 'MI_RENEWAL_PREMIUM_id'
    field :loan_id,             column: 'loanGeneral_Id'
    field :sequence,            column: '_Sequence'
    field :rate,                column: '_Rate'

    alias_attribute :loan_general_id, :loan_id

    # scopes
    def self.first_premium
      where(sequence: 'First').order('liability_id ASC').first
    end

    # TODO: Figure out how to make it so we don't need to declare this
    # in each model and just keep it in the parent module.
    def self.sqlserver_create_view
      self.build_query
    end
  end
end
