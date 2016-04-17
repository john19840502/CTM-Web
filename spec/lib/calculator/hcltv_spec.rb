require 'calculator/ltv_calculator_base'
require 'calculator/hcltv'

describe Hcltv do
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

  let(:hcltv_result) { Hcltv.new(options) }
  let(:hcltv_loan) { Hcltv.new() }

  it 'return 0 if there is a no product code for the loan' do
    expect(hcltv_loan.missing_product_code?).to eq(true)
  end

  it 'sets the subordinate lein amount' do
    hcltv_result.set_subordinate_total
    expect(hcltv_result.subordinate_total).to eq(5500.0)
  end

  it 'adds up the total' do
    hcltv_result.set_subordinate_total
    hcltv_result.set_total
    expect(hcltv_result.total).to eq(105550.0)
  end

  it 'checks if the product is USDA30FXD' do
    options[:product_code] = 'USDA30FXD'
    expect(hcltv_result.usda30fxd?).to eq(true)
  end

  it 'checks if the product type is purchase' do
    options[:purpose_type] = 'Purchase'
    expect(hcltv_result.purchase?).to eq(true)
  end

  it 'checks if the product type is refinance' do
    options[:purpose_type] = 'Refinance'
    expect(hcltv_result.refinance?).to eq(true)
  end

  it 'returns true if the purpose type is "ConstructionOnly"' do
    options[:purpose_type] = 'ConstructionOnly'
    expect(hcltv_result.kind_of_construction?).to eq(true)
  end
    
  it 'returns true if the purpose type is "Other"' do
    options[:purpose_type] = 'Other'
    expect(hcltv_result.kind_of_construction?).to eq(true)
  end

  it 'returns true if the purpose type is "ConstructionToPermanent"' do
    options[:purpose_type] = 'ConstructionToPermanent'
    expect(hcltv_result.kind_of_construction?).to eq(true)
  end
    
  it 'returns false if the purpose type is "Purchase"' do
    options[:purpose_type] = 'Purchase'
    expect(hcltv_result.kind_of_construction?).to eq(false)
  end

  describe 'calculation scenarios' do
    it 'calculates non-usda3fxd and purpose type of purchase' do
      options[:purpose_type]            = 'Purchase'
      expect(hcltv_result.call).to eq(84.44)
    end

    it 'calculates non-usda3fxd and purpose type of refinance' do
      options[:purpose_type]                    = 'Refinance'
      expect(hcltv_result.call).to eq(84.44)
    end

    it 'calculates usda3fxd and purpose type that is a kind of construction ' do
      options[:product_code]                    = 'USDA30FXD'
      options[:purpose_type]                    = 'ConstructionOnly'
      expect(hcltv_result.call).to eq(84.44)
    end

    it 'calculates non-usda3fxd and purpose type that is a kind of construction ' do
      options[:purpose_type]                    = 'ConstructionOnly'
      expect(hcltv_result.call).to eq(84.44)
    end

    it 'calculates usda3fxd and purpose type of purchase' do
      options[:product_code]                    = 'USDA30FXD'
      options[:purpose_type]                    = 'Purchase'
      expect(hcltv_result.call).to eq(84.44)
    end

    it 'calculates usda3fxd and purpose type of refinance' do
      options[:product_code]                    = 'USDA30FXD'
      options[:purpose_type]                    = 'Refinance'
      expect(hcltv_result.call).to eq(84.44)
    end

    it 'calculates usda3fxd' do
      options[:product_code]                    = 'USDA30FXD'
      options[:purpose_type]                    = 'Something'
      expect(hcltv_result.call).to eq(84.44)
    end

    it 'returns a cltv of 0 if anything else' do
      options[:product_code]                    = 'Some Product'
      options[:purpose_type]                    = 'Something'
      expect(hcltv_result.call).to eq(0.0)
    end
  end

end
