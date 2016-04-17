require 'translation/loan_serv_product_code'

describe Translation::LoanServProductCode do
  describe 'initialize' do
    let(:options) { nil }

    subject { Translation::LoanServProductCode.new(options) }

    context 'with product code specified' do
      let(:options) { 'C15FXD' }

      its(:product_code) { should == 'C15FXD' }
    end
  end
end
