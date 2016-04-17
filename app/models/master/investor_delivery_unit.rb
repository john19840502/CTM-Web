require 'ctm/ms_sql_view'
module Master
  class InvestorDeliveryUnit < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView

    # relations
    belongs_to :loan, class_name: 'Master::Loan', inverse_of: :investor_delivery_units

    from 'INVESTOR_DELIVERY_UNIT', as: 'idu'

    field :id,                  column: 'INVESTOR_DELIVERY_UNIT_id'
    field :loan_id,             column: 'loanGeneral_Id'
    field :number_of_bedrooms,  column: 'NumberofBedrooms'
    field :eligible_rent,       column: 'EligibleRent'
    field :unit_position,       column: 'UnitPosition'

    def self.sqlserver_create_view
      self.build_query
    end

    def self.number_of_bedrooms_for unit_number
      where(unit_position: unit_number).first.try(:number_of_bedrooms) || 0
    end

    def self.eligible_rent_for unit_number
      where(unit_position: unit_number).first.try(:eligible_rent) || 0
    end
  end
end
