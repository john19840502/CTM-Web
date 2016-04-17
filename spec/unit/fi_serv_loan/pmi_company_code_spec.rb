require 'ostruct'
require 'fi_serv_loan'
describe FiServLoan do
  subject { FiServLoan.new(loan) }

  describe 'wrapping a loan with mi_company_id: RMIC and mortgage_type: Conventional' do
    let(:loan) { OpenStruct.new(mi_company_id: 1672, mortgage_type: 'Conventional') }

    its(:pmi_company_code) { should == '13' }
  end

  describe 'wrapping a loan with mi_company_id: RMIC and mortgage_type: FHA' do
    let(:loan) { OpenStruct.new(mi_company_id: 3124, mortgage_type: 'FHA') }

    its(:pmi_company_code) { should == 'FR' }
  end

  describe 'wrapping a loan with mi_company_id: RMIC and mortgage_type: FarmersHomeAdministration' do
    let(:loan) { OpenStruct.new(mi_company_id: 3124, mortgage_type: 'FarmersHomeAdministration') }

    its(:pmi_company_code) { should == '  ' }
  end
end
