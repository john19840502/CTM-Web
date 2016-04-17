require 'calculator/ltv_calculator_base'
require 'calculator/cltv'

describe Cltv do
  let(:options) { 
    {
      product_code: "USDA15FXD", 
      purpose_type: "Purchase",
      base_loan_amount: 100000, 
      purchase_price_amount: 150000, 
      property_appraised_value_amount: 125000, 
      subordinate_lien_amount: 5000,
      subordinate_lien_heloc_amount: 500,
      liability_amount: 50,
      mi_and_funding_fee_total_amount: 0,
      undrawn_heloc_amount: 500
    } 
  }

  let(:cltv_result) { Cltv.new(options) }
  let(:cltv_loan) {Cltv.new() }

  it 'return 0 if there is a no product code for the loan' do
    expect(cltv_loan.missing_product_code?).to eq true
  end

  it 'sets the subordinate lein amount' do
    options[:subordinate_lien_amount] = 199
    cltv_result.set_subordinate_total
    expect(cltv_result.subordinate_total).to eq(199)
  end

  it 'adds up the total' do
    cltv_result.set_subordinate_total
    cltv_result.set_total
    expect(cltv_result.total).to eq(105050)
  end

  it 'checks if the product is USDA30FXD' do
    options[:product_code] = 'USDA30FXD'
    expect(cltv_result.usda30fxd?).to eq true
  end

  it 'checks if the product type is purchase' do
    expect(cltv_result.purchase?).to eq true
  end

  it 'checks if the product type is refinance' do
    options[:purpose_type] = 'Refinance'
    expect(cltv_result.refinance?).to eq true
  end

  it 'returns true if the purpose type is "ConstructionOnly"' do
    options[:purpose_type] = 'ConstructionOnly'
    expect(cltv_result.kind_of_construction?).to eq true
  end
    
  it 'returns true if the purpose type is "Other"' do
    options[:purpose_type] = 'Other'
    expect(cltv_result.kind_of_construction?).to eq true
  end

  it 'returns true if the purpose type is "ConstructionToPermanent"' do
    options[:purpose_type] = 'ConstructionToPermanent'
    expect(cltv_result.kind_of_construction?).to eq true
  end
    
  it 'returns false if the purpose type is "Purchase"' do
    expect(cltv_result.kind_of_construction?).to eq false
  end

  describe 'detemining the lesser of property apprasied value and purchase price amount' do
    it 'returns purchase price amount when 2 non-zero values are present' do
      options[:property_appraised_value_amount] = 100
      options[:purchase_price_amount] = 75
      expect(cltv_result.appraised_or_purchase_amount).to eq 75
    end

    it 'returns property_appraised_value_amount when purchase price amount is 0' do
      options[:property_appraised_value_amount] = 80
      options[:purchase_price_amount] = 0
      expect(cltv_result.appraised_or_purchase_amount).to eq 80
    end

    it 'returns 0 if both property appraised value amoutn and purchase price amount are 0' do
      options[:property_appraised_value_amount] = 0
      options[:purchase_price_amount] = 0
      expect(cltv_result.appraised_or_purchase_amount).to eq 0
    end
  end


  describe 'calculation scenarios' do
    it 'calculates non-usda3fxd and purpose type of purchase' do
      expect(cltv_result.call).to eq 84.04
    end

    it 'calculates non-usda3fxd and purpose type of refinance' do
      options[:purpose_type] = 'Refinance'
      expect(cltv_result.call).to eq 84.04
    end

    it 'calculates usda3fxd and purpose type that is a kind of construction ' do
      options[:product_code] = 'USDA30FXD'
      options[:purpose_type] = 'ConstructionOnly'
      expect(cltv_result.call).to eq 84.04
    end

    it 'calculates non-usda3fxd and purpose type that is a kind of construction ' do
      options[:purpose_type] = 'ConstructionOnly'
      expect(cltv_result.call).to eq 84.04
    end

    it 'calculates usda3fxd and purpose type of purchase' do
      options[:product_code] = 'USDA30FXD'
      expect(cltv_result.call).to eq 84.04
    end

    it 'calculates usda3fxd and purpose type of refinance' do
      options[:product_code] = 'USDA30FXD'
      options[:purpose_type] = 'Refinance'
      expect(cltv_result.call).to eq 84.04
    end

    it 'calculates usda3fxd' do
      options[:product_code] = 'USDA30FXD'
      options[:purpose_type] = 'Something'
      expect(cltv_result.call).to eq 84.04
    end

    it 'returns a cltv of 0 if anything else' do
      options[:product_code] = 'Some Product'
      options[:purpose_type] = 'Something'
      expect(cltv_result.call).to eq 0.0
    end
  end

end
