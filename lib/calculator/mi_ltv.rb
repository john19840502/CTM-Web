require 'calculator/ltv_calculator_base'

class MiLtv < LtvCalculatorBase
  # cltv, hcltv and ltv return 0 if product code is missing
  # they also set totals -- things we don't need to do here
  def call
    (calculate * 100).round(3)
  end

  def calculate
    return 0 if property_appraised_value_amount == 0
    base_loan_amount / property_appraised_value_amount
  end
end
