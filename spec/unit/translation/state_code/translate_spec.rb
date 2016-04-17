require 'translation/state_code'

describe Translation::StateCode do
  describe 'translate' do
    let(:options) { nil }

    subject { Translation::StateCode.new(options) }

    context 'with state_abbreviation = AL' do
      let(:options) { 'AL' }

      its(:translate) { should == '01' }
    end

    context 'with state_abbreviation = MI' do
      let(:options) { 'MI' }

      its(:translate) { should == '23' }
    end

    context 'with mortgage_type = something weird' do
      let(:options) { 'SOMETHING WEIRD' }

      its(:translate) { should == nil }
    end
  end
end
