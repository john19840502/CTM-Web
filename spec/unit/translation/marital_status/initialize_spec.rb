require 'translation/marital_status'

describe Translation::MaritalStatus do
  describe 'initialize' do
    let(:options) { nil }

    subject { Translation::MaritalStatus.new(options) }

    context 'with Married' do
      let(:options) { 'Married' }

      its(:marital_status_type) { should == 'Married' }
    end
  end
end
