require 'translation/loan_type_number'

describe Translation::LoanTypeNumber do
  describe 'initialize' do
    let(:options) { nil }

    subject { Translation::LoanTypeNumber.new(options) }

    context 'with options(mortgage_type and mi_indicator) specified' do
      let(:options) { {mortgage_type: 'Conventional', mi_indicator: 2} }

      its(:mortgage_type) { should == 'Conventional' }
      its(:mi_indicator) { should == 2 }
    end
  end
end
