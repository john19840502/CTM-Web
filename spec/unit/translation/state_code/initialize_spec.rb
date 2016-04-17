require 'translation/state_code'

describe Translation::StateCode do
  describe 'initialize' do
    let(:options) { nil }

    subject { Translation::StateCode.new(options) }

    context 'with state_abbreviation specified' do
      let(:options) { 'AL' }

      its(:state_abbreviation) { should == 'AL' }
    end
  end
end
