require 'translation/loan_type_number'

describe Translation::LoanTypeNumber do
  describe 'translate' do
    let(:options) { nil }

    subject { Translation::LoanTypeNumber.new(options) }

    context 'with mortgage_type = Conventional' do
      let(:options) { {mortgage_type: 'Conventional'} }

      context 'mi_indicator = 2' do
        before { options.merge!({mi_indicator: 2}) }

        its(:translate) { should == nil }
      end

      context 'and mi_indicator is true' do
        before { options.merge!({mi_indicator: true}) }

        its(:translate) { should == 8 }
      end

      context 'and mi_indicator = false' do
        before { options.merge!({mi_indicator: false}) }

        its(:translate) { should == 1 }
      end
    end

    context 'with mortgage_type = FHA' do
      let(:options) { {mortgage_type: 'FHA'} }

      its(:translate) { should == 2}
    end

    context 'with mortgage_type = FarmersHomeAdministration' do
      let(:options) { {mortgage_type: 'FarmersHomeAdministration'} }

      its(:translate) { should == 9}
    end

    context 'with mortgage_type = VA' do
      let(:options) { {mortgage_type: 'VA'} }

      its(:translate) { should == 3}
    end

    context 'with mortgage_type = Other' do
      let(:options) { {mortgage_type: 'Other'} }

      its(:translate) { should == 9}
    end

    context 'with mortgage_type = ""' do
      let(:options) { {mortgage_type: ''} }

      its(:translate) { should == 9}
    end

    context 'with mortgage_type = something weird' do
      let(:options) { {mortgage_type: 'KLJKLJ'} }

      its(:translate) { should == nil }
    end
  end
end
