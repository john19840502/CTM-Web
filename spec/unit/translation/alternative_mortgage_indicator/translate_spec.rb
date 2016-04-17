require 'translation/alternative_mortgage_indicator'

describe Translation::AlternativeMortgageIndicator do
  describe 'translate' do
    let(:options) { nil }

    subject { Translation::AlternativeMortgageIndicator.new(options) }

    context 'with amortization_type = Fixed' do
      let(:options) { 'Fixed' }

      its(:translate) { should == 0 }
    end

    context 'with amortization_type = ""' do
      let(:options) { '' }

      its(:translate) { should == 0 }
    end

    context 'with amortization_type = OtherAmortizationType' do
      let(:options) { 'OtherAmortizationType' }

      its(:translate) { should == 1}
    end

    context 'with amortization_type = SomethingWeird' do
      let(:options) { 'SomethingWeird' }

      its(:translate) { should == nil }
    end
  end
end
