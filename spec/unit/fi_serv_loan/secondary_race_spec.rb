require 'ostruct'
require 'fi_serv_loan'
describe FiServLoan do
  subject { FiServLoan.new(loan) }

  describe 'wrapping a loan with secondary_hmda_race_type: Asian' do
    let(:loan) { OpenStruct.new(secondary_hmda_race_type: 'Asian') }

    its(:secondary_hmda_race_type)   { should == 'Asian' }
    its(:secondary_race)             { should == 2 }
  end
end