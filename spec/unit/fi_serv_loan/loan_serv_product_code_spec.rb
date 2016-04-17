require 'ostruct'
require 'fi_serv_loan'
describe FiServLoan do
  subject { FiServLoan.new(loan) }

  describe 'wrapping a loan with product_code: C15FXD' do
    let(:loan) { OpenStruct.new(product_code: 'C15FXD') }

    its(:product_code)           { should == 'C15FXD' }
    its(:loan_serv_product_code) { should == 'C15FX' }
  end

  describe 'wrapping a loan with product_code: FHA30 MSHDA NH' do
    let(:loan) { OpenStruct.new(product_code: 'FHA30 MSHDA NH') }

    its(:product_code)           { should == 'FHA30 MSHDA NH' }
    its(:loan_serv_product_code) { should == 'F30MN' }
  end
end