require 'ostruct'
require 'fi_serv_loan'
describe FiServLoan do
  subject { FiServLoan.new(loan) }

  describe 'wrapping a loan with primary_marital_status_type: Female' do
    let(:loan) { OpenStruct.new(primary_marital_status_type: 'Married') }

    its(:primary_marital_status_type)   { should == 'Married' }
    its(:primary_marital_status)        { should == 'M' }
  end
end