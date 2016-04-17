require 'translation/pmi_company_code'

describe Translation::PmiCompanyCode do
  describe 'translate' do
    let(:options) { nil }

    subject { Translation::PmiCompanyCode.new(options) }

    { 1673 => '06',
      3124 => '01',
      1674 => '12',
      1672 => '13',
      1671 => '33',
      8352 => '43'
    }.each do |company, translation|
      context "with mi_company_id = #{company}" do
        let(:options) { {mi_company_id: company} }

        its(:translate) { should == translation }
      end
    end

    context 'with mortgage_type = FHA' do
      let(:options) { { mortgage_type: 'FHA' } }

      its(:translate) { should == 'FR' }
    end

    context 'with mortgage_type = FarmersHomeAdministration' do
      let(:options) { { mortgage_type: 'FarmersHomeAdministration' } }

      its(:translate) { should == '  ' }
    end
  end
end
