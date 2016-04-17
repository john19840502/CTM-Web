require 'calculator/ltv_calculator_base'
require 'calculator/mi_ltv'

describe MiLtv do
  let (:options) {
    {
      base_loan_amount: 130000,
      property_appraised_value_amount: 150000,
      product_code: "USDA15FXD",
      property_state: 'NY',
      purpose_tyoe: "Purchase",
      lock_loan_property_state: 'NY'
    }
  }

  let (:mi_ltv_result) { MiLtv.new(options) }
  let (:mi_loan) { MiLtv.new() }

  describe 'calculation scenarios' do
    it 'should return the calculated value for NY state' do
      expect(mi_ltv_result.call).to eq(86.667)
    end

    it 'should return 0 when the property_appraised_value_amount is 0' do
      options[:property_appraised_value_amount] = 0
      expect(mi_ltv_result.call).to eq(0)
    end
  end
end
