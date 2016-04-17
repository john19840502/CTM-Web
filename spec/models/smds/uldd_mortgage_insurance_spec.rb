require 'spec_helper'
describe Smds::UlddMortgageInsurance do

  let(:loan) { double }
  let(:mi) { Smds::UlddMortgageInsurance.new loan }

  before do
    loan.stub LoanType: 'Conventional'
    loan.stub delivery_type: 'FHLMC'
    setup_common_mi_prereqs
    loan.stub loan_general: FactoryGirl.build_stubbed(:loan_general)
    loan.loan_general.stub_chain(:lock_loan_datum, mi_indicator: true)
  end

  describe "primary_absence_reason" do
    context "PrimaryMIAbsenceReasonType for FNMA loans" do
      before { loan.stub delivery_type: 'FNMA'}
      it "should return when LoanType is Conventional" do
        loan.stub LoanType: 'Non Conventional'
        expect(mi.primary_absence_reason).to eq ''
      end

      it "should return '' when the mi_indicator is true" do
        expect(mi.primary_absence_reason).to eq ''
      end

      it "should return NoMIBasedOnOriginalLTV when LTV <= 80" do
        loan.stub LTV: 80
        set_mi_indicator_false
        expect(mi.primary_absence_reason).to eq 'NoMIBasedOnOriginalLTV'
      end

      it "return MICanceledBasedOnCurrentLTV when LTV > 80 and loan is not MI" do
        set_mi_indicator_false
        expect(mi.primary_absence_reason).to eq 'MICanceledBasedOnCurrentLTV'
      end
    end

    context "For FHLMC loans only" do
      it "should return when LoanType is Conventional" do
        loan.stub LoanType: 'Non Conventional'
        expect(mi.primary_absence_reason).to eq ''
      end

      it "should return '' when the mi_indicator is true" do
        expect(mi.primary_absence_reason).to eq ''
      end

      it "should return NoMIBasedOnOriginalLTV when LTV <= 80" do
        loan.stub LTV: 80
        set_mi_indicator_false
        expect(mi.primary_absence_reason).to eq 'NoMIBasedOnOriginalLTV'
      end

      it "should return Other when relief loan" do
        loan.stub ProductCode: 'lsfj FR'
        set_mi_indicator_false
        expect(mi.primary_absence_reason).to eq 'Other'
      end

      it "return MICanceledBasedOnCurrentLTV when LTV > 80, not a relief loan and loan is not MI" do 
        set_mi_indicator_false
        expect(mi.primary_absence_reason).to eq 'MICanceledBasedOnCurrentLTV'
      end
    end
  end

  describe "primary_absence_reason_other_desc " do
    before {set_mi_indicator_false}
    it "should return NoMIBasedOnMortgageBeingRefinanced if primary_absence_reason is Other" do
      loan.stub ProductCode: 'lsfj FR'
      expect(mi.primary_absence_reason_other_desc).to eq 'NoMIBasedOnMortgageBeingRefinanced'
    end

    it "should return '' when the primary_absence_reason is not other" do
      expect(mi.primary_absence_reason_other_desc).to eq ''
    end
  end

  describe "certificate_identifier" do
    it "should return Cert number when it's not nil and not NA" do
      loan.stub MICertNbr: 'a'*50 + 'foo'
      expect(mi.certificate_identifier).to eq 'a'*50
    end

    it "should report blank when the certificate identifier is missing" do
      ['NA', nil, ''].each do |value|
        loan.stub MICertNbr: value
        mi.certificate_identifier.should == ''
      end
    end

    it "should return '' when mi indicator is false" do
      set_mi_indicator_false
      loan.stub MICertNbr: '2345678'
      expect(mi.certificate_identifier).to eq ''
    end 
  end

  describe "#coverage_percent" do
    it "should be blank when MiCoveragePct is 0" do
      loan.stub MiCoveragePct: 0
      loan.stub LTV: 91
      loan.stub LnAmortTerm: 250
      mi.coverage_percent.should == '30.0000'
    end

    it "should round to 4 decimal places" do
      loan.stub MiCoveragePct: 123.456789
      mi.coverage_percent.should == '123.4568'
    end

    it "should return '' when MI flag is false" do
      set_mi_indicator_false
      loan.stub MiCoveragePct: 345
      expect(mi.coverage_percent).to eq ''
    end
  end

  describe "#coverage_percent_fnma" do
    it "should be blank when MiCoveragePct is 0" do
      loan.stub MiCoveragePct: 0
      loan.stub LTV: 82
      loan.stub LnAmortTerm: 156
      mi.coverage_percent_fnma.should == '6'
    end

    it "should round to 4 decimal places" do
      loan.stub MiCoveragePct: 123.56
      mi.coverage_percent_fnma.should == '124'
    end

    it "should return '' when MI flag is false" do
      set_mi_indicator_false
      loan.stub MiCoveragePct: 345
      expect(mi.coverage_percent_fnma).to eq ''
    end
  end

  describe "#company_name" do
    [ [ 'GENWORTH FINANCIAL', 'Genworth' ],
      [ 'GE', 'Genworth' ],
      [ 'MGIC', 'MGIC' ],
      [ 'PMI', 'PMI' ],
      [ 'UNITED GUARANTY', 'UGI' ],
      [ 'RMIC', 'RMIC' ],
      [ 'CMG', 'CMG' ],
      [ 'RADIAN', 'Radian' ],
      [ 'ESSENT GUARANTY', 'Essent' ],
    ].each do |original, expected|
      it "should translate #{original} to #{expected}" do
        loan.stub MICompanyName: original
        mi.company_name.should == expected
      end
    end

    it "the company name should be blank otherwise" do
      ['lsdfj', nil, 'NA'].each do |name|
        loan.stub MICompanyName: name
        mi.company_name.should == ''
      end
    end

    it "should return '' when mi indicator is false" do
      set_mi_indicator_false
      loan.stub MICompanyName: 'UGI'
      expect(mi.company_name).to eq ''
    end
  end

  describe "#premium_financed_amount" do
    it "should return '' when FinancedMIAmt is 0" do
      loan.stub FinancedMIAmt: 0
      expect(mi.premium_financed_amount).to eq ''
    end

    it "should return '' when mi indicator is false" do
      set_mi_indicator_false
      loan.stub FinancedMIAmt: 123
      expect(mi.premium_financed_amount).to eq ''
    end

    it "should return amount when FinancedMIAmt > 0" do
      loan.stub FinancedMIAmt: 123.45
      expect(mi.premium_financed_amount).to eq '123.45'
    end
  end

  context "When the MI Indicator is false" do
    before do 
      set_mi_indicator_false
    end

    it { mi.certificate_identifier.should == '' }
    it { mi.company_name.should == '' }
    it { mi.coverage_percent.should == '' }
    it { mi.premium_financed_indicator.should == '' }
    it { mi.premium_financed_amount.should == '' }
    it { mi.premium_source.should == '' }
    it { mi.lender_paid_rate_adjustment.should == '' }
  end

  context "When the MI Indicator is true" do
    before do
      loan.stub FinancedMIAmt: 123.45
      loan.stub LenderPaidMiFlg: 'Y'
      loan.stub LenderMIPaidRtPct: 0
    end

    it { mi.certificate_identifier.should == '12345' }
    it { mi.company_name.should == 'UGI' }
    it { mi.coverage_percent.should == '50.0000' }
    it { mi.premium_financed_indicator.should == 'true' }
    it { mi.premium_financed_amount.should == '123.45' }
    it { mi.premium_source.should == 'Lender' }
    it { mi.lender_paid_rate_adjustment.should == '' }

  end

  context "Relief loans" do
    before do
      loan.stub ProductCode: 'lsfj FR'
      loan.loan_general.stub_chain(:lock_loan_datum, mi_indicator: false)
    end
    
    it { mi.certificate_identifier.should == '' }
    it { mi.company_name.should == '' }
    it { mi.coverage_percent.should == '' }
    it { mi.premium_financed_indicator.should == '' }
    it { mi.premium_financed_amount.should == '' }
    it { mi.premium_source.should == '' }
    it { mi.lender_paid_rate_adjustment.should == '' }
  end

  context "conventional, non-relief loans with currltv > 80" do
    
    context "When there is a financed MI amount" do
      before { loan.stub FinancedMIAmt: 123.456 }

      it { mi.premium_financed_indicator.should == 'true' }
      it { mi.premium_financed_amount.should == '123.46'}
    end

    context "When there is no financed MI amount" do
      before { loan.stub FinancedMIAmt: 0 }

      it { mi.premium_financed_indicator.should == 'false' }
      it { mi.premium_financed_amount.should == '' }
    end

    context "When the MI is lender paid" do
      before do
        loan.stub LenderPaidMiFlg: 'Y'
      end

      it { mi.premium_source.should == 'Lender' }

      it "should show Lender even if the cert nbr is missing" do
        loan.stub MICertNbr: 'NA'
        mi.premium_source.should == 'Lender'
      end

      it "should be blank when LenderMIPaidRtPct is 0" do
        loan.stub :LenderMIPaidRtPct => 0
        mi.lender_paid_rate_adjustment.should == ''
      end

      it "should round to 4 places" do
        loan.stub :LenderMIPaidRtPct => 123.45678
        mi.lender_paid_rate_adjustment.should == '123.46'
      end
    end

    context "When the MI is not lender paid" do
      before { loan.stub LenderPaidMiFlg: 'N' }

      it { mi.premium_source.should == 'Borrower' }

      it "should leave the lender paid rate blank" do
        loan.stub LenderPaidMiFlg: 50
        mi.lender_paid_rate_adjustment.should == ''
      end
    end
  end

  def setup_common_mi_prereqs
    loan.stub LTV: 81
    loan.stub CurrLTV: 81
    loan.stub MICertNbr: '12345'
    loan.stub MICompanyName: 'UNITED GUARANTY'
    loan.stub MiCoveragePct: 50
    loan.stub ProductCode: 'C30FXD'
  end

  def set_mi_indicator_false
    loan.loan_general.stub_chain(:lock_loan_datum, mi_indicator: false)
  end

end
