require 'translation/purpose'

describe Translation::Purpose do
  describe 'initialize' do
    let(:options) { nil }

    subject { Translation::Purpose.new(options) }

    context 'with options(purpose_type and property_usage_type) specified' do
      let(:options) { {purpose_type: 'Purchase', property_usage_type: 'PrimaryResidence'} }

      its(:purpose_type)        { should == 'Purchase' }
      its(:property_usage_type) { should == 'PrimaryResidence' }
    end
  end
end
