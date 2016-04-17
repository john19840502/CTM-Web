require 'translation/asset_type_code'

describe Translation::AssetTypeCode do
  describe 'translate' do
    let(:options) { nil }

    subject { Translation::AssetTypeCode.new(options) }

    context 'with asset_type = TrustAccount' do
      let(:options) { 'TrustAccount' }

      its(:translate) { should == 3 }
    end

    context 'with asset_type = Stock' do
      let(:options) { 'Stock' }

      its(:translate) { should == 4 }
    end

    context 'with asset_type = something weird' do
      let(:options) { 'SOMETHING WEIRD' }

      its(:translate) { should == nil }
    end
  end
end
