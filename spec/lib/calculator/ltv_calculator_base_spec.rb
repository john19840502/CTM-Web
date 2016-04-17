require 'calculator/ltv_calculator_base'

describe LtvCalculatorBase do

  describe 'appraised_or_purchase_amount' do 
    it 'appraised value lower' do 
      ltv = LtvCalculatorBase.new({:property_appraised_value_amount => 10000, :purchase_price_amount => 20000})
      ltv.appraised_or_purchase_amount.should == 10000
    end
    it 'purchase price lower' do
      ltv = LtvCalculatorBase.new({:property_appraised_value_amount => 30000, :purchase_price_amount => 20000})
      ltv.appraised_or_purchase_amount.should == 20000
    end
  end
end
