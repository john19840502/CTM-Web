require 'ostruct'
require 'fi_serv_loan'
describe FiServLoan do
  subject { FiServLoan.new(loan) }

  describe 'wrapping a loan with purpose_type: Purchase, property_usage_type: PrimaryResidence' do
    let(:loan) { OpenStruct.new(purpose_type: 'Purchase', property_usage_type: 'PrimaryResidence') }

    its(:purpose_type)         { should == 'Purchase' }
    its(:property_usage_type)  { should == 'PrimaryResidence'}
    its(:application_purpose)  { should == 11 }
  end
end