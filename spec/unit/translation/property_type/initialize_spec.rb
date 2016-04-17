require 'translation/property_type'

describe Translation::PropertyType do
  describe 'initialize' do
    let(:options) { nil }

    subject { Translation::PropertyType.new(options) }

    context 'with gse_property_type specified' do
      let(:options) { 'DetachedCondominium' }

      its(:gse_property_type) { should == 'DetachedCondominium' }
    end
  end
end
