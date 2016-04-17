require 'spec_helper'
require 'hmda_transformations'

describe Compliance::Hmda::HmdaTransformations do
  # let(:loan_general) { LoanGeneral.new }

  # let(:some_random_loan) { make_new_loan }

  # before do
  #   Loan.stub(:find_by_loan_num).and_return(some_random_loan)
  # end

  let(:event) { LoanComplianceEvent.create(aplnno: 1111111, appname:"ABEL ALEXANDER", propstreet:"123 Alice Ave", propcity:"Somewhere", 
      propstate: "NY", propzip:"12345", apdate:"2012-08-30", lntype:1, proptype:1, 
      lnpurpose: 3, occupancy:1, lnamount:78, preappr:3, action_code:1, actdate:"2012-11-26",
      apeth: 2, capeth:2, aprace:5, caprace:5, apsex:1, capsex:2, 
      tincome: "69", purchtype:nil, denialr1:nil, denialr2:nil, 
      denialr3: nil, apr:"3.716", spread:nil, lockdate:"2012-11-02", loan_term:120, 
      hoepa: 2, lienstat:1, qltychk:"N", createdate:"2012-08-28", channel:2, finaldate:"2012-09-06 14:37:00", 
      initadjmos: nil, apptakenby:"M", occupyurla:"P", branchid:nil, branchname:nil, institutionid:31, loanrep:45678, 
      loanrepname: "BIFF LOANREPGUY", note_rate:"2.875", pntsfees:"3044.14", broker:"56789", 
      brokername: "BIG FANCY BANK CORP.", ltv:"22.838", cltv:"22.838", debt_ratio:"24.991", comb_ratio:"27.847", 
      apcrscore: 795, capcrscore:786, penalty:2, loan_prog:"Conforming 15yr Fixed", marital:1, 
      maritalc: 1, apl_age:"19560131", co_apl_age:34, cash_out:2, doc_type:2, amort_term:120, 
      amorttype: "F", apprvalue:"340000", lender_fee:"780.58", broker_fee:"3570.12", orig_fee: nil, 
      disc_pnt: 0, dpts_dl: nil, houseprp:"1441.07", mnthdebt:"1605.73", transformed: false) }
  
  describe 'transformations' do
    let(:period) { 'm' }
    let(:loan) { make_new_loan }
    before do 
      event.stub(:loan_general).and_return(loan)
      loan.stub_chain(:investor_lock, :investor_lock_expires_on) { Date.yesterday }
      loan.stub_chain(:investor_lock, :investor_name) { "foo" }
      loan.stub(:is_preapproval?) { true }
      event.stub(:record_changes)
    end

    it "should set action_code to 8 when preapproval is 1, property address is TBD, and action_code is 2" do
      event[:propstreet] = 'TBD'
      event[:preappr] = 1
      event[:action_code] = 2
      Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
      event.reload
      event[:action_code].should == 8
    end

    it "should set action_code to 7 when preapproval is 1, property address is TBD, and action_code is 3" do
      event[:propstreet] = 'TBD'
      event[:preappr] = 1
      event[:action_code] = 3
      Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
      event.reload
      event[:action_code].should == 7
    end

    [:propstreet, :propcity, :propstate].each do |thing|
      it "should not crash when #{thing} is nil" do
        event[:preappr] = 1
        event[thing] = nil
        Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
      end
    end

    [ 2, 3, 4, 5, 6, 7, 8 ].each do |i|
      it "when the action_code code is #{i} and the lock date is not null, set the lock date to null" do
        event[:lockdate] = "2012-01-20"
        event[:action_code] = i
        Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
        event.reload
        event[:lockdate].should == nil
      end

      it "when the action_code code is #{i}, set the APR to N/A if APR is not blank" do
        event[:apr] = "3.176"
        event[:action_code] = i
        Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
        event.reload
        event[:apr].should == "NA"
      end

      it "when the action_code code is #{i}, set the APR to N/A if APR is blank" do
        event[:apr] = ""
        event[:action_code] = i
        Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
        event.reload
        event[:apr].should == "NA"
      end

      it "when the action_code code is #{i}, set the rate spread to N/A" do
        event[:spread] = "1.006"
        event[:action_code] = i
        Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
        event.reload
        event[:spread].should == "NA"
      end
    end

    it "should set preappr to 3 when the loan is RO" do
      loan.stub(:is_preapproval?) { false }
      loan.stub(:channel) { Channel.reimbursement.identifier }
      event[:preappr] = 1
      Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
      event.reload
      event[:preappr].should == 3
    end

    it "should set preappr to 3 when the loan is RO for post TRID" do
      loan.stub(:is_preapproval?) { false }
      loan.stub(:channel) { Channel.reimbursement.identifier }
      event[:preappr] = 1
      event[:actdate] = '2016-02-07'
      Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
      event.reload
      event[:preappr].should == 3
    end

    [ Channel.wholesale.identifier, Channel.retail.identifier, Channel.consumer_direct.identifier ].each do |channel|
      it "should leave preappr unchanged when the loan is #{channel}" do
        loan.stub(:channel) { channel }
        event[:preappr] = 1
        Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
        event.reload
        event[:preappr].should == 1
      end
    end

    [ Channel.wholesale.identifier, Channel.retail.identifier, Channel.consumer_direct.identifier ].each do |channel|
      it "should changed preappr to 3 when the loan is #{channel} if loan is post TRID" do
        loan.stub(:channel) { channel }
        event[:preappr] = 1
        event[:actdate] = '2016-02-07'
        Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
        event.reload
        event[:preappr].should == 3
      end
    end

    it "should seet preappr to 3 for refinance loans" do
      loan.stub(:is_preapproval?) { false }
      loan.stub(:is_refi?) { true }
      loan.stub(:is_purchase?) { false }
      event[:preappr] = 1
      Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
      event.reload
      event[:preappr].should == 3
    end

    it "should set preappr to 3 for loan action_codes on May 7 2012" do
      loan.stub(:is_preapproval?) { false }
      loan.stub(:is_refi?) { false }
      event[:preappr] = 1
      event[:actdate] = '2012-05-07'
      Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
      event.reload
      event[:preappr].should == 3
    end

    it "should set preappr to 3 for loan action_codes before May 7 2012" do
      loan.stub(:is_preapproval?) { false }
      loan.stub(:is_refi?) { false }
      event[:preappr] = 1
      event[:actdate] = '2012-05-03'
      Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
      event.reload
      event[:preappr].should == 3
    end

    it "should leave preappr alone for loans after May 7 2012" do
      event[:preappr] = 1
      event[:actdate] = '2012-05-13'
      Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
      event.reload
      event[:preappr].should == 1
    end

    it "should change preappr to 3 for post TRID loans" do
      event[:preappr] = 1
      event[:actdate] = '2016-02-13'
      Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
      event.reload
      event[:preappr].should == 3
    end

    it "should set the purch type to whatever the hash says it should be" do 
      HmdaInvestorCode.stub investor_codes: { '13' => [ 'foo' ]}
      Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
      event.reload
      event[:purchtype].should == 13    
    end

    it "should set the purch type to somethjing when the inv name is not found" do 
      event[:purchtype] = 300
      HmdaInvestorCode.stub investor_codes: { '13' => [ 'bar' ]}
      Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
      event.reload
      event[:purchtype].should == 300    
    end

    it "should save the investor name" do
      Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
      event.reload
      event[:investor_name].should == "foo"
    end

    it "should set tincome to N/A for VA IRRL or employee loans" do
      event[:loan_prog] = 'VA 30yr IRRL'
      Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
      event.reload
      event[:tincome].should == "NA"
    end

    it "should set tincome to N/A for FHA Streamline loans when tincome is blank" do
      event[:tincome] = ''
      event[:loan_prog] = 'FHA Streamline'
      Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
      event.reload
      event[:tincome].should == "NA"
    end

    it "should not set tincome to N/A for FHA Streamline loans when tincome is not blank" do
      event[:tincome] = '25000'
      event[:loan_prog] = 'FHA 30yrs'
      Compliance::Hmda::HmdaTransformations.new(event, period).do_transformations
      event.reload
      event[:tincome].should == "25000"
    end

  end

  def make_new_loan
    LoanGeneral.new 
  end
end