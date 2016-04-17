require 'ostruct'
require 'fi_serv_loan'
describe FiServLoan do
  subject { FiServLoan.new(loan) }

  describe 'wrapping a loan with primary_hmda_ethnicity_type: HispanicOrLatino' do
    let(:loan) { OpenStruct.new(primary_hmda_ethnicity_type: 'HispanicOrLatino') }

    its(:primary_hmda_ethnicity_type)   { should == 'HispanicOrLatino' }
    its(:primary_ethnicity)             { should == 1 }
  end
end