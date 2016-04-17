require 'ostruct'
require 'fi_serv_loan'
describe FiServLoan do
  subject { FiServLoan.new(loan) }

  describe 'wrapping a loan with purpose_type: Purchase and property_usage_type: Investor' do
    let(:loan) { OpenStruct.new(purpose_type: 'Purchase', property_usage_type: 'Investor') }

    its(:purpose)             { should == 17 }
    its(:application_purpose) { should == 17 }
  end
end