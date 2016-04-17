require 'spec_helper'

describe LoanModeler do
  
  let(:loan) { Loan.new }

  before do
    loan.stub_chain(:hud_lines, :hud, :hud_line_value) { 1234 }
    loan.stub_chain(:hud_lines, :hud, :hud_map_value) { 1234 }
    loan.stub_chain(:hud_lines, :hud, :hud_ary_value) { 1234 }

    #pre trid
    loan.stub_chain(:hud_lines, :hud_line_value_pre_trid) { 1234 }
    loan.stub_chain(:hud_lines, :hud_map_value) { 1234 }
    loan.stub_chain(:hud_lines, :hud_ary_value) { 1234 }

    loan.stub_chain(:hud_lines, :hud, :with_category) { 1234 }
    loan.stub_chain(:hud_lines, :hud, :with_category_and_fee_name_start_with) { 1234 }

    loan.stub(:trid_loan?).and_return(false)
  end

  describe "#wholesale" do 
    it "channel should equal wholesale" do
      loan.stub_chain(:account_info, :channel) { 'W0-Wholesale Standard'}
      loan.send(:wholesale).should be true
    end
  end

  describe "#fha" do
    it "mortgage type should equal fha" do
      loan.stub_chain(:mortgage_term, :mortgage_type) { 'FHA'}
      loan.send(:fha).should be true
    end
  end

  describe "#hudline" do
    it "should return value" do
      loan.send(:hudline, 'Origination Fee').should be_truthy
    end
  end

  describe "#origination_fee_modeler" do
    before do
      loan.stub_chain(:account_info, :channel) { channel_name }
      loan.stub_chain(:mortgage_term, :mortgage_type) { mortgage_type_name }
    end
    context "wholesale loan" do 
      let(:channel_name) { 'W0-Wholesale Standard' }
      context "wholesale loan and dodd frank not nil" do
        it "should return dodd frank value" do
          loan.stub_chain(:dodd_frank_modeler, :origination_fee) { 5432 }
          loan.origination_fee_modeler.should == 5432
        end
      end
      context "wholesale loan and dodd frank nil" do
        it "should return 0" do
          loan.stub(:dodd_frank_modeler) { nil }
          loan.origination_fee_modeler.should == 0.0
        end
      end
    end
    context "not wholsale loan" do
      let(:channel_name) { 'Not Wholesale' }
      context "fha loan" do 
        let(:mortgage_type_name) { 'FHA' }
        context "fha loan and dodd frank not nil" do
          it "should return dodd frank value" do
            loan.stub_chain(:dodd_frank_modeler, :origination_fee) { 5432 }
            loan.origination_fee_modeler.should == 5432
          end
        end
        context "fha loan and dodd frank nil" do
          it "should return hudline value" do
            loan.stub(:dodd_frank_modeler) { nil }
            loan.origination_fee_modeler.should == 1234
          end
        end
      end
      context "dodd frank nil" do
        let(:mortgage_type_name) { 'NRA' }
        it "should return hudline value" do
          loan.stub(:dodd_frank_modeler) { nil }
          loan.origination_fee_modeler.should == 1234
        end
      end
    end
  end

  describe "#origination_fee_fund_modeler" do
    before do
      loan.stub_chain(:account_info, :channel) { channel_name }
    end
    context "wholesale loan" do 
      let(:channel_name) { 'W0-Wholesale Standard' }
      context "and funding not nil" do
        it "should return funding value" do
          loan.stub_chain(:funding_modeler, :origination_fee) { 5432 }
          loan.origination_fee_fund_modeler.should == 5432
        end
      end
      context "and funding nil" do
        it "should return 0" do
          loan.stub(:funding_modeler) { nil }
          loan.origination_fee_fund_modeler.should == 0.0
        end
      end
    end
    context "not wholsale loan" do
      let(:channel_name) { 'Not Wholesale' }
      context "and funding nil" do
        it "should return hudline value" do
          loan.stub(:funding_modeler) { nil }
          loan.origination_fee_fund_modeler.should == 1234
        end
      end
    end
  end

  describe "#appraisal_fee_modeler" do
    before do
      loan.stub_chain(:mortgage_term, :mortgage_type) { mortgage_type_name }
    end
    context "fha loan" do 
      let(:mortgage_type_name) { 'FHA' }
      context "and dodd frank not nil" do
        it "should return dodd frank value" do
          loan.stub_chain(:dodd_frank_modeler, :appraisal_fee) { 5432 }
          loan.appraisal_fee_modeler.should == 5432
        end
      end
      context "and dodd frank nil" do
        it "should return hudline value" do
          loan.stub(:dodd_frank_modeler) { nil }
          loan.appraisal_fee_modeler.should == 1234
        end
      end
    end
    context "dodd frank nil" do
      let(:mortgage_type_name) { 'NRA' }
      it "should return hudline value" do
        loan.stub(:dodd_frank_modeler) { nil }
        loan.appraisal_fee_modeler.should == 1234
      end
    end
  end

  describe "#appraisal_fee_fund_modeler" do
    before do
      loan.stub_chain(:account_info, :channel) { channel_name }
    end
    context "wholesale loan" do 
      let(:channel_name) { 'W0-Wholesale Standard' }
      context "and funding not nil" do
        it "should return funding value" do
          loan.stub_chain(:funding_modeler, :appraisal_fee) { 5432 }
          loan.appraisal_fee_fund_modeler.should == 5432
        end
      end
      context "and funding nil" do
        it "should return 0" do
          loan.stub(:funding_modeler) { nil }
          loan.appraisal_fee_fund_modeler.should == 0.0
        end
      end
    end
    context "not wholsale loan" do
      let(:channel_name) { 'Not Wholesale' }
      context "and funding nil" do
        it "should return hudline value" do
          loan.stub(:funding_modeler) { nil }
          loan.appraisal_fee_fund_modeler.should == 1234
        end
      end
    end
  end

  describe "#credit_report_modeler" do
    before do
      loan.stub_chain(:mortgage_term, :mortgage_type) { mortgage_type_name }
    end
    context "fha loan" do 
      let(:mortgage_type_name) { 'FHA' }
      context "and dodd frank not nil" do
        it "should return dodd frank value" do
          loan.stub_chain(:dodd_frank_modeler, :credit_report) { 5432 }
          loan.credit_report_modeler.should == 5432
        end
      end
      context "and dodd frank nil" do
        it "should return hudline value" do
          loan.stub(:dodd_frank_modeler) { nil }
          loan.credit_report_modeler.should == 1234
        end
      end
    end
    context "dodd frank nil" do
      let(:mortgage_type_name) { 'NRA' }
      it "should return hudline value" do
        loan.stub(:dodd_frank_modeler) { nil }
        loan.credit_report_modeler.should == 1234
      end
    end
  end

  describe "#credit_report_fund_modeler" do
    before do
      loan.stub_chain(:account_info, :channel) { channel_name }
    end
    context "wholesale loan" do 
      let(:channel_name) { 'W0-Wholesale Standard' }
      context "and funding not nil" do
        it "should return funding value" do
          loan.stub_chain(:funding_modeler, :credit_report) { 5432 }
          loan.credit_report_fund_modeler.should == 5432
        end
      end
      context "and funding nil" do
        it "should return 0" do
          loan.stub(:funding_modeler) { nil }
          loan.credit_report_fund_modeler.should == 0.0
        end
      end
    end
    context "not wholsale loan" do
      let(:channel_name) { 'Not Wholesale' }
      context "and funding nil" do
        it "should return hudline value" do
          loan.stub(:funding_modeler) { nil }
          loan.credit_report_fund_modeler.should == 1234
        end
      end
    end
  end

  describe "#flood_cert_modeler" do
    before do
      loan.stub_chain(:mortgage_term, :mortgage_type) { mortgage_type_name }
    end
    context "fha loan" do 
      let(:mortgage_type_name) { 'FHA' }
      context "and dodd frank not nil" do
        it "should return dodd frank value" do
          loan.stub_chain(:dodd_frank_modeler, :flood_cert) { 5432 }
          loan.flood_cert_modeler.should == 5432
        end
      end
      context "and dodd frank nil" do
        it "should return hudline value" do
          loan.stub(:dodd_frank_modeler) { nil }
          loan.flood_cert_modeler.should == 1234
        end
      end
    end
    context "dodd frank nil" do
      let(:mortgage_type_name) { 'NRA' }
      it "should return hudline value" do
        loan.stub(:dodd_frank_modeler) { nil }
        loan.flood_cert_modeler.should == 1234
      end
    end
  end

  describe "#interim_interest_modeler" do
    before do
      loan.stub_chain(:mortgage_term, :mortgage_type) { mortgage_type_name }
    end
    context "fha loan" do 
      let(:mortgage_type_name) { 'FHA' }
      context "and dodd frank not nil" do
        it "should return dodd frank value" do
          loan.stub_chain(:dodd_frank_modeler, :interim_interest) { 5432 }
          loan.interim_interest_modeler.should == 5432
        end
      end
      context "and dodd frank nil" do
        it "should return hudline value" do
          loan.stub(:dodd_frank_modeler) { nil }
          loan.interim_interest_modeler.should == 1234
        end
      end
    end
    context "dodd frank nil" do
      let(:mortgage_type_name) { 'NRA' }
      it "should return hudline value" do
        loan.stub(:dodd_frank_modeler) { nil }
        loan.interim_interest_modeler.should == 1234
      end
    end
  end

  describe "#escrow_modeler" do
    before do
      loan.stub_chain(:mortgage_term, :mortgage_type) { mortgage_type_name }
    end
    context "fha loan" do 
      let(:mortgage_type_name) { 'FHA' }
      context "and dodd frank not nil" do
        it "should return dodd frank value" do
          loan.stub_chain(:dodd_frank_modeler, :escrow) { 5432 }
          loan.escrow_modeler.should == 5432
        end
      end
      context "and dodd frank nil" do
        it "should return hudline value" do
          loan.stub(:dodd_frank_modeler) { nil }
          loan.escrow_modeler.should == 1234
        end
      end
    end
    context "dodd frank nil" do
      let(:mortgage_type_name) { 'NRA' }
      it "should return hudline value" do
        loan.stub(:dodd_frank_modeler) { nil }
        loan.escrow_modeler.should == 1234
      end
    end
  end

  describe "#title_fees_modeler" do
    before do
      loan.stub_chain(:mortgage_term, :mortgage_type) { mortgage_type_name }
    end
    context "fha loan" do 
      let(:mortgage_type_name) { 'FHA' }
      context "and dodd frank not nil" do
        it "should return dodd frank value" do
          loan.stub_chain(:dodd_frank_modeler, :title_fees) { 5432 }
          loan.title_fees_modeler.should == 5432
        end
      end
      context "and dodd frank nil" do
        it "should return hudline value" do
          loan.stub(:dodd_frank_modeler) { nil }
          loan.title_fees_modeler.should == 3702
        end
      end
    end
    context "dodd frank nil" do
      let(:mortgage_type_name) { 'NRA' }
      it "should return hudline value" do
        loan.stub(:dodd_frank_modeler) { nil }
        loan.title_fees_modeler.should == 3702
      end
    end
  end

  describe "#owner_policy_modeler" do
    before do
      loan.stub_chain(:mortgage_term, :mortgage_type) { mortgage_type_name }
    end
    context "fha loan" do 
      let(:mortgage_type_name) { 'FHA' }
      context "and dodd frank not nil" do
        it "should return dodd frank value" do
          loan.stub_chain(:dodd_frank_modeler, :owner_policy) { 5432 }
          loan.owner_policy_modeler.should == 5432
        end
      end
      context "and dodd frank nil" do
        it "should return hudline value" do
          loan.stub(:dodd_frank_modeler) { nil }
          loan.owner_policy_modeler.should == 1234
        end
      end
    end
    context "dodd frank nil" do
      let(:mortgage_type_name) { 'NRA' }
      it "should return hudline value" do
        loan.stub(:dodd_frank_modeler) { nil }
        loan.owner_policy_modeler.should == 1234
      end
    end
  end

  describe "#recording_fees_modeler" do
    before do
      loan.stub_chain(:mortgage_term, :mortgage_type) { mortgage_type_name }
    end
    context "fha loan" do 
      let(:mortgage_type_name) { 'FHA' }
      context "and dodd frank not nil" do
        it "should return dodd frank value" do
          loan.stub_chain(:dodd_frank_modeler, :recording_fees) { 5432 }
          loan.recording_fees_modeler.should == 5432
        end
      end
      context "and dodd frank nil" do
        it "should return hudline value" do
          loan.stub(:dodd_frank_modeler) { nil }
          loan.recording_fees_modeler.should == 1234
        end
      end
    end
    context "dodd frank nil" do
      let(:mortgage_type_name) { 'NRA' }
      it "should return hudline value" do
        loan.stub(:dodd_frank_modeler) { nil }
        loan.recording_fees_modeler.should == 1234
      end
    end
  end

  describe "#transfer_taxes_modeler" do
     before do
      loan.stub_chain(:mortgage_term, :mortgage_type) { mortgage_type_name }
    end
    context "fha loan" do 
      let(:mortgage_type_name) { 'FHA' }
      context "and dodd frank not nil" do
        it "should return dodd frank value" do
          loan.stub_chain(:dodd_frank_modeler, :transfer_taxes) { 5432 }
          loan.transfer_taxes_modeler.should == 5432
        end
      end
      context "and dodd frank nil" do
        it "should return hudline value" do
          loan.stub(:dodd_frank_modeler) { nil }
          loan.transfer_taxes_modeler.should == 1234
        end
      end
    end
    context "dodd frank nil" do
      let(:mortgage_type_name) { 'NRA' }
      it "should return hudline value" do
        loan.stub(:dodd_frank_modeler) { nil }
        loan.transfer_taxes_modeler.should == 1234
      end
    end
  end

  describe "#misc_fees_modeler" do
    before do
      loan.stub_chain(:mortgage_term, :mortgage_type) { mortgage_type_name }
    end
    let(:index) { 1 }
    let(:line_number) { 801 }

    context "fha loan" do 
      let(:mortgage_type_name) { 'FHA' }
      context "and dodd frank not nil" do
        it "should return dodd frank value" do
          loan.stub_chain(:dodd_frank_modeler, :misc_fees_1) { 5432 }
          loan.misc_fees_modeler(index, line_number).should == 5432
        end
      end
      context "and dodd frank nil" do
        it "should return hudline value" do
          loan.stub(:dodd_frank_modeler) { nil }
          loan.misc_fees_modeler(index, line_number).should == 1234
        end
      end
    end
    context "dodd frank nil" do
      let(:mortgage_type_name) { 'NRA' }
      it "should return hudline value" do
        loan.stub(:dodd_frank_modeler) { nil }
        loan.misc_fees_modeler(index, line_number).should == 1234
      end
    end
  end
end
