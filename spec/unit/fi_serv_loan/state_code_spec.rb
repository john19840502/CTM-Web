require 'ostruct'
require 'fi_serv_loan'
require 'fiserv'
describe FiServLoan do
  subject { FiServLoan.new(loan) }

  describe 'wrapping a loan with property_state: AL' do
    let(:loan) { OpenStruct.new(property_state: 'AL') }

    its(:property_state) { should == 'AL' }
    its(:state_code)     { should == '01' }
  end
end
