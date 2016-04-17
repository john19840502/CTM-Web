require 'ostruct'
require 'fi_serv_loan'
describe FiServLoan do
  subject { FiServLoan.new(loan) }

  describe 'wrapping a loan with secondary_hmda_ethnicity_type: HispanicOrLatino' do
    let(:loan) { OpenStruct.new(secondary_hmda_ethnicity_type: 'HispanicOrLatino') }

    its(:secondary_hmda_ethnicity_type)   { should == 'HispanicOrLatino' }
    its(:secondary_ethnicity)             { should == 1 }
  end
end