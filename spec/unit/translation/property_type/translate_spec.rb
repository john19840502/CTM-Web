require 'translation/property_type'

describe Translation::PropertyType do
  describe 'translate' do
    let(:options) { nil }

    subject { Translation::PropertyType.new(options) }

    context 'with DetachedCondominium' do
      let(:options) { 'DetachedCondominium' }

      its(:translate) { should == 16 }
    end

    context 'with ManufacturedHousing' do
      let(:options) { 'ManufacturedHousing' }

      its(:translate) { should == 81 }
    end

    context 'with blank type' do
      let(:options) { '' }

      its(:translate) { should == '' }
    end

    context 'with mortgage_type = something weird' do
      let(:options) { 'KLJKLJ' }

      its(:translate) { should == nil }
    end
  end
end
