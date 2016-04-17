require 'calculator/ltv_calculator_base'

class Ltv < LtvCalculatorBase
  def calculate
    return calculate_non_usda30fxd_and_refinance  if !usda30fxd? && refinance?
    return calculate_non_usda30fxd_and_purchase if !usda30fxd? && purchase?
    return calculate_non_usda30fxd_and_other_purpose if !usda30fxd? && kind_of_construction?
    return calculate_just_usda30fxd if usda30fxd?
    return 0
  end

  def calculate_non_usda30fxd_and_refinance
    return 0 if property_appraised_value_amount == 0
    base_loan_amount / property_appraised_value_amount
  end

  def calculate_non_usda30fxd_and_purchase
    return 0 if appraised_or_purchase_amount == 0
    base_loan_amount / appraised_or_purchase_amount
  end

  def calculate_non_usda30fxd_and_other_purpose
    return 0 if appraised_or_purchase_amount == 0
    base_loan_amount / appraised_or_purchase_amount
  end

  def calculate_just_usda30fxd
    return 0 if property_appraised_value_amount == 0
    (base_loan_amount + mi_and_funding_fee_total_amount) / property_appraised_value_amount
  end 
end
