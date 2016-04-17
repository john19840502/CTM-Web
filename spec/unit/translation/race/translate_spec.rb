require 'translation/race'

describe Translation::Race do
  describe 'translate' do
    let(:options) { nil }

    subject { Translation::Race.new(options) }

    context 'with race_type = BlackOrAfricanAmerican' do
      let(:options) { 'BlackOrAfricanAmerican' }

      its(:translate) { should == 3 }
    end

    context 'with race_type = White' do
      let(:options) { 'White' }

      its(:translate) { should == 5 }
    end

    context 'with race_type = something weird' do
      let(:options) { 'SOMETHING WEIRD' }

      its(:translate) { should == nil }
    end
  end
end
