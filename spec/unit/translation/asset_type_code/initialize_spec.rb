require 'translation/asset_type_code'

describe Translation::AssetTypeCode do
  describe 'initialize' do
    let(:options) { nil }

    subject { Translation::AssetTypeCode.new(options) }

    context 'with Automobile' do
      let(:options) { 'Automobile' }

      its(:asset_type) { should == 'Automobile' }
    end
  end
end
