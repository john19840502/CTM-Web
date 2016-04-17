require 'translation/pmi_company_code'

describe Translation::PmiCompanyCode do
  describe 'initialize' do
    let(:options) { nil }

    subject { Translation::PmiCompanyCode.new(options) }

    context 'with options(mi_company_id and mortgage_type) specified' do
      let(:options) { {mi_company_id: 3124, mortgage_type: 'Conventional'} }

      its(:mi_company_id)  { should == 3124 }
      its(:mortgage_type)  { should == 'Conventional' }
    end
  end
end
