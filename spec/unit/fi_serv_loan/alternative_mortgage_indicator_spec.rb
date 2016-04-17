require 'ostruct'
require 'fi_serv_loan'
describe FiServLoan do
  subject { FiServLoan.new(loan) }

  describe 'wrapping a loan with loan_amortization_type: AdjustableRate' do
    let(:loan) { OpenStruct.new(loan_amortization_type: 'AdjustableRate') }

    its(:loan_amortization_type)         { should == 'AdjustableRate' }
    its(:alternative_mortgage_indicator) { should == 1 }
  end
end