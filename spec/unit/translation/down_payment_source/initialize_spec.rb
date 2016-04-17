require 'translation/down_payment_source'

describe Translation::DownPaymentSource do
  describe 'initialize' do
    let(:options) { nil }

    subject { Translation::DownPaymentSource.new(options) }

    context 'with CheckingSavings' do
      let(:options) { 'CheckingSavings' }

      its(:down_payment_type) { should == 'CheckingSavings' }
    end
  end
end
