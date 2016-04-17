require 'translation/down_payment_type_code'

describe Translation::DownPaymentTypeCode do
  describe 'translate' do
    let(:options) { nil }

    subject { Translation::DownPaymentTypeCode.new(options) }

    context 'with down_payment_type = CheckingSavings' do
      let(:options) { 'CheckingSavings' }

      its(:translate) { should == 'H' }
    end

    context 'with down_payment_type = UnsecuredBorrowerFunds' do
      let(:options) { 'UnsecuredBorrowerFunds' }

      its(:translate) { should == 'D' }
    end

    context 'with down_payment_type = something weird' do
      let(:options) { 'SOMETHING WEIRD' }

      its(:translate) { should == nil }
    end
  end
end
