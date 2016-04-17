require 'ostruct'
require 'fi_serv_loan'
describe FiServLoan do
  subject { FiServLoan.new(loan) }

  describe 'wrapping a loan with primary_hmda_race_type: Asian' do
    let(:loan) { OpenStruct.new(primary_hmda_race_type: 'Asian') }

    its(:primary_hmda_race_type)   { should == 'Asian' }
    its(:primary_race)             { should == 2 }
  end
end