require 'ostruct'
require 'fi_serv_loan'
describe FiServLoan do
  subject { FiServLoan.new(loan) }

  describe 'wrapping a loan with secondary_gender_type: Female' do
    let(:loan) { OpenStruct.new(secondary_gender_type: 'Female') }

    its(:secondary_gender_type)   { should == 'Female' }
    its(:secondary_gender)        { should == 'F' }
  end
end