require 'ctm/ms_sql_view'
module Master
  class HudLine < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView

    attr_accessible :monthly_amount

    # relations
    belongs_to :loan, class_name: 'Master::Loan'

    from 'HUD_LINE', as: 'hud'

    field :id,                  column: 'hud_line_id'
    field :loan_id,             column: 'loanGeneral_Id'
    field :hud_type,            column: 'hudType'
    field :line_num,            column: '_LineNumber'
    field :system_fee_name,     column: '_SystemFeeName'
    field :fee_category,        column: 'FeeCategory'
    field :total_amount,        column: '_TotalAmount'
    field :monthly_amount,      column: '_MonthlyAmount'
    field :user_defined_fee_name, column: '_UserDefinedFeeName'
    field :rate_percent,        column: '_RatePercent'
    field :num_months,          column: '_NumberOfMonths'
    field :paid_by,             column: '_PaidBy'
    field :net_fee_indicator,   column: 'NetFeeIndicator'

    alias_attribute :loan_general_id, :loan_id

    # scopes
    scope :gfe, ->{ where(:hud_type => 'GFE') }
    scope :hud, ->{ where(:hud_type => 'HUD') }

    #constants
    LINE_NUMBER_LOOKUP = {:hazard_insurance    => 1002, 
                          :mortgage_insurance  => 1003,
                          :city_property_tax   => 1004,
                          :county_property_tax => 1005,
                          :annual_assessments   => 1006,
                          :assessment          => 1006,
                          :flood_insurance     => 1007,
                          :other               => [1008, 1009]}

    # TODO: Figure out how to make it so we don't need to declare this
    # in each model and just keep it in the parent module.
    def self.sqlserver_create_view
      self.build_query
    end

  end
end
