require 'translation/down_payment_type_code'

describe Translation::DownPaymentTypeCode do
  describe 'initialize' do
    let(:options) { nil }

    subject { Translation::DownPaymentTypeCode.new(options) }

    context 'with BridgeLoan given' do
      let(:options) { 'BridgeLoan' }

      its(:down_payment_type) { should == 'BridgeLoan' }
    end
  end
end
