require 'ostruct'
require 'fi_serv_loan'
describe FiServLoan do
  subject { FiServLoan.new(loan) }

  describe 'wrapping a loan with mortgage_type: "Conventional", mi_indicator: true' do
    let(:loan) { OpenStruct.new(mortgage_type: 'Conventional', mi_indicator: true, has_mi?: true) }
    its(:mortgage_type)    { should == 'Conventional' }
    its(:mi_indicator)     { should == true }
    its(:loan_type_number) { should == 8 }
  end

  describe 'wrapping a loan with mortgage_type: "Conventional", mi_indicator: false' do
    let(:loan) { OpenStruct.new(mortgage_type: 'Conventional', mi_indicator: false, has_mi?: false) }
    its(:mortgage_type)    { should == 'Conventional' }
    its(:mi_indicator)     { should == false }
    its(:loan_type_number) { should == 1 }
  end

  context "when loan type is FarmersHomeAdministration" do
    let(:loan) { OpenStruct.new(mortgage_type: 'FarmersHomeAdministration', mi_indicator: true, has_mi?: true) }
    its(:loan_type_number) { should == 9 }
  end

end
