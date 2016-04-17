require 'translation/ethnicity'

describe Translation::Ethnicity do
  describe 'translate' do
    let(:options) { nil }

    subject { Translation::Ethnicity.new(options) }

    context 'with ethnicity_type = HispanicOrLatino' do
      let(:options) { 'HispanicOrLatino' }

      its(:translate) { should == 1 }
    end

    context 'with ethnicity_type = NotHispanicOrLatino' do
      let(:options) { 'NotHispanicOrLatino' }

      its(:translate) { should == 2 }
    end

    context 'with ethnicity_type = something weird' do
      let(:options) { 'SOMETHING WEIRD' }

      its(:translate) { should == nil }
    end
  end
end
