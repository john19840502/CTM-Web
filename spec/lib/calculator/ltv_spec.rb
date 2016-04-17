require 'calculator/ltv_calculator_base'
require 'calculator/ltv'

describe Ltv do
  let(:options) {
    {
      mi_and_funding_fee_total_amount: 100,
      product_code: "USDA15FXD",
      base_loan_amount: 130000,
      purchase_price_amount: 150000,
      property_appraised_value_amount: 150000
    }
  }

  let(:ltv_result) { Ltv.new(options) }
  let(:ltv_loan) { Ltv.new() }

  describe 'calculation scenarios' do
    it "calculates non-usda3fxd and purpose type of purchase" do
      options[:purchase_price_amount] = 140000
      options[:purpose_type] = "Purchase"
      expect(ltv_result.call).to eq(92.857)
    end

    it "calculates non-usda3fxd and purpose type of refinance" do
      options[:purpose_type] = "Refinance"
      expect(ltv_result.call).to eq(86.667)
    end

    it "calculates usda30fxd when purpose type is a kind of construction" do
      options[:purpose_type] = "ConstructionOnly"
      options[:product_code] = "USDA30FXD"
      expect(ltv_result.call).to eq(86.733)
    end

    it "calculates non-usda30fxd when purpose type is a kind of construction" do
      options[:purpose_type] = "ConstructionOnly"
      expect(ltv_result.call).to eq(86.667)
    end

    it "returns 0 when none of the conditions are met" do
      options[:purpose_type] = "SomethingElse"
      expect(ltv_result.call).to eq(0)
    end
  end

end

