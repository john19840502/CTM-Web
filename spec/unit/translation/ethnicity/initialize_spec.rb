require 'translation/ethnicity'

describe Translation::Ethnicity do
  describe 'initialize' do
    let(:options) { nil }

    subject { Translation::Ethnicity.new(options) }

    context 'with HispanicOrLatino' do
      let(:options) { 'HispanicOrLatino' }

      its(:ethnicity_type) { should == 'HispanicOrLatino' }
    end
  end
end
