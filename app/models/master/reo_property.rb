require 'ctm/ms_sql_view'
module Master
  class ReoProperty < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView

    # relations
    belongs_to :loan, class_name: 'Master::Loan', inverse_of: :reo_property

    from 'REO_PROPERTY', as: 'rp'

    field :id,                                  column: 'REO_PROPERTY_id'
    field :loan_id,                             column: 'loanGeneral_Id'
    field :reo_id,                              column: 'REO_ID'
    field :borrower_id,                         column: 'BorrowerID'
    field :liability_id,                        column: 'LiabilityID'
    field :street_address,                      column: '_StreetAddress'
    field :city,                                column: '_City'
    field :state,                               column: '_State'
    field :postal_code,                         column: '_PostalCode'
    field :current_residence_indicator,         column: '_CurrentResidenceIndicator'
    field :disposition_status_type,             column: '_DispositionStatusType'
    field :gse_property_type,                   column: '_GSEPropertyType'
    field :lien_installment_amount,             column: '_LienInstallmentAmount'
    field :lien_upb_amount,                     column: '_LienUPBAmount'
    field :maintenance_expense_amount,          column: '_MaintenanceExpenseAmount'
    field :market_value_amount,                 column: '_MarketValueAmount'
    field :rental_income_gross_amount,          column: '_RentalIncomeGrossAmount'
    field :rental_income_net_amount,            column: '_RentalIncomeNetAmount'
    field :subject_indicator,                   column: '_SubjectIndicator'

    alias_attribute :loan_general_id, :loan_id

    scope :subject, ->{ where(:subject_indicator => 1) }

    # TODO: Figure out how to make it so we don't need to declare this
    # in each model and just keep it in the parent module.
    def self.sqlserver_create_view
      self.build_query
    end

  end
end
