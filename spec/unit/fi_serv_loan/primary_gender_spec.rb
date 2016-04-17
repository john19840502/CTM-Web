require 'ostruct'
require 'fi_serv_loan'
describe FiServLoan do
  subject { FiServLoan.new(loan) }

  describe 'wrapping a loan with primary_gender_type: Female' do
    let(:loan) { OpenStruct.new(primary_gender_type: 'Female') }

    its(:primary_gender_type)   { should == 'Female' }
    its(:primary_gender)        { should == 'F' }
  end
end