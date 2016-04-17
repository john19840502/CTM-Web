require 'translation/application_purpose'

describe Translation::ApplicationPurpose do
  describe 'translate' do
    let(:options) { nil }

    subject { Translation::ApplicationPurpose.new(options) }

    context 'with purpose_type = Purchase' do
      let(:options) { {purpose_type: 'Purchase'} }

      context 'and property_usage_type = SecondHome' do
        before { options.merge!({property_usage_type: 'SecondHome'}) }

        its(:translate) { should == 16 }
      end
    end
  end
end
