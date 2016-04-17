require 'translation/purpose'

describe Translation::Purpose do
  describe 'translate' do
    let(:options) { nil }

    subject { Translation::Purpose.new(options) }

    context 'with purpose_type = Purchase' do
      let(:options) { {purpose_type: 'Purchase'} }

      context 'and property_usage_type = SecondHome' do
        before { options.merge!({property_usage_type: 'SecondHome'}) }

        its(:translate) { should == 16 }
      end
    end
  end
end
