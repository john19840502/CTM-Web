require 'ostruct'
require 'fi_serv_loan'
describe FiServLoan do
  subject { FiServLoan.new(loan) }

  describe 'wrapping a loan with institution_identifier: 123456' do
    let(:loan) { OpenStruct.new(institution_identifier: '123456') }

    its(:branch)         { should == '12345' }
  end
end