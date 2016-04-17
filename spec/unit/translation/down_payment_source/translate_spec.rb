require 'translation/down_payment_source'

describe Translation::DownPaymentSource do
  describe 'translate' do
    let(:options) { nil }

    subject { Translation::DownPaymentSource.new(options) }

    context 'with down_payment_type = CheckingSavings' do
      let(:options) { 'CheckingSavings' }

      its(:translate) { should == '07' }
    end

    context 'with down_payment_type = GiftFunds' do
      let(:options) { 'GiftFunds' }

      its(:translate) { should == '01' }
    end

    context 'with down_payment_type = something weird' do
      let(:options) { 'SOMETHING WEIRD' }

      its(:translate) { should == nil }
    end
  end
end
