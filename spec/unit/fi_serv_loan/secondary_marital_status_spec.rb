require 'ostruct'
require 'fi_serv_loan'
describe FiServLoan do
  subject { FiServLoan.new(loan) }

  describe 'wrapping a loan with secondary_marital_status_type: Female' do
    let(:loan) { OpenStruct.new(secondary_marital_status_type: 'Married') }

    its(:secondary_marital_status_type)   { should == 'Married' }
    its(:secondary_marital_status)        { should == 'M' }
  end
end