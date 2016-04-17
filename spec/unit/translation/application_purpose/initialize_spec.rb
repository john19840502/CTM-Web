require 'translation/application_purpose'

describe Translation::ApplicationPurpose do
  describe 'initialize' do
    let(:options) { nil }

    subject { Translation::ApplicationPurpose.new(options) }

    context 'with options(purpose_type and property_usage_type) specified' do
      let(:options) { {purpose_type: 'Purchase', property_usage_type: 'PrimaryResidence'} }

      its(:purpose_type)        { should == 'Purchase' }
      its(:property_usage_type) { should == 'PrimaryResidence' }
    end
  end
end
