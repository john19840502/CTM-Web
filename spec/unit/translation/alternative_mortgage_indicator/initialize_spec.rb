require 'translation/alternative_mortgage_indicator'

describe Translation::AlternativeMortgageIndicator do
  describe 'initialize' do
    let(:options) { nil }

    subject { Translation::AlternativeMortgageIndicator.new(options) }

    context 'with amortization type specified' do
      let(:options) { 'Fixed' }

      its(:amortization_type) { should == 'Fixed' }
    end
  end
end
