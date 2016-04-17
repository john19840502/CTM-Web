require 'translation/marital_status'

describe Translation::MaritalStatus do
  describe 'translate' do
    let(:options) { nil }

    subject { Translation::MaritalStatus.new(options) }

    context 'with marital_status_type = Married' do
      let(:options) { 'Married' }

      its(:translate) { should == 'M' }
    end

    context 'with marital_status_type = Separated' do
      let(:options) { 'Separated' }

      its(:translate) { should == 'S' }
    end

    context 'with marital_status_type = something weird' do
      let(:options) { 'SOMETHING WEIRD' }

      its(:translate) { should == nil }
    end
  end
end
