require 'ostruct'
require 'fi_serv_loan'
describe FiServLoan do
  subject { FiServLoan.new(loan) }

  describe 'wrapping a loan with gse_property_type: Detached' do
    let(:loan) { OpenStruct.new(gse_property_type: 'Detached') }

    its(:gse_property_type) { should == 'Detached' }
    its(:property_type)     { should == 10 }
  end
end