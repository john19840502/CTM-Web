require 'translation/race'

describe Translation::Race do
  describe 'initialize' do
    let(:options) { nil }

    subject { Translation::Race.new(options) }

    context 'with race type specified' do
      let(:options) { 'White' }

      its(:race_type) { should == 'White' }
    end
  end
end
