require 'translation/loan_serv_product_code'

describe Translation::LoanServProductCode do
  describe 'translate' do
    let(:options) { nil }

    subject { Translation::LoanServProductCode.new(options) }

    context 'with product_code = C15FXD' do
      let(:options) { 'C15FXD' }

      its(:translate) { should == 'C15FX' }
    end

    context 'with product_code = ""' do
      let(:options) { '' }

      its(:translate) { should == nil }
    end

    context 'with product_code = FHA30FXD' do
      let(:options) { 'FHA30FXD' }

      its(:translate) { should == 'F30FX'}
    end

    context 'with amortization_type = SomethingWeird' do
      let(:options) { 'SomethingWeird' }

      its(:translate) { should == nil }
    end
  end
end
