require 'spec_helper'
require 'lar_file_importer'

describe Compliance::Hmda::LarFileImporter do

  subject { Compliance::Hmda::LarFileImporter.new }
  let(:loan_general) { LoanGeneral.new }
  let(:some_random_loan) { make_new_loan }

  before do
    Loan.stub(:find_by_loan_num).and_return(some_random_loan)
  end

  HEADER_LINE = "APLNNO,APPNAME,PROPSTREET,PROPCITY,PROPSTATE,PROPZIP,SUBINCL,APDATE,LNTYPE,PROPTYPE,LNPURPOSE,OCCUPANCY,LNAMOUNT,PREAPPR,Action,ACTDATE,MACODE,STCODE,CNTYCODE,CENSUSTRCT,APETH,CAPETH,APRACE,CAPRACE,APSEX,CAPSEX,TINCOME,PURCHTYPE,DENIALR1,DENIALR2,DENIALR3,APR,TREASEC,SPREAD,LOCKDATE,LOAN_TERM,HOEPA,LIENSTAT,QLTYCHK,CREATEDATE,CHANNEL,FINALDATE,INITADJMOS,APPTAKENBY,OCCUPYURLA,BRANCHID,BRANCHNAME,INSTITUTIONID,LOANREP,LOANREPNAME,NOTE_RATE,PNTSFEES,BROKER,BROKERNAME,LTV,CLTV,DEBT_RATIO,COMB_RATIO,APCRSCORE,CAPCRSCORE,PENALTY,LOAN_PROG,MARITAL,MARITALC,APL_AGE,CO_APL_AGE,CASH_OUT,DOC_TYPE,AMORT_TERM,AMORTTYPE,APPRVALUE,LENDER_FEE,BROKER_FEE,ORIG_FEE,DISC_PNT,DPTS_DL,HOUSEPRP,MNTHDEBT\n"

  let(:sample_data) do
    { :aplnno=>"1111111", :appname=>"ABEL ALEXANDER", :propstreet=>"123 Alice Ave", :propcity=>"Somewhere", 
      :propstate=>"NY", :propzip=>"12345", :subincl=>"Y", :apdate=>"8/30/2012", :lntype=>"1", :proptype=>"1", 
      :lnpurpose=>"3", :occupancy=>"1", :lnamount=>"78", :preappr=>"3", :action=>"1", :actdate=>"11/26/2012", 
      :macode=>"NA", :stcode=>"36", :cntycode=>"69", :censustrct=>"NA", :apeth=>"2", :capeth=>"2", :aprace=>"5", 
      :caprace=>"5", :apsex=>"1", :capsex=>"2", :tincome=>"69", :purchtype=>nil, :denialr1=>nil, :denialr2=>nil, 
      :denialr3=>nil, :apr=>"3.716", :treasec=>nil, :spread=>nil, :lockdate=>"11/2/2012", :loan_term=>"120", 
      :hoepa=>"2", :lienstat=>"1", :qltychk=>"N", :createdate=>"8/28/2012", :channel=>"2", :finaldate=>"9/6/2012 14:37", 
      :initadjmos=>nil, :apptakenby=>"M", :occupyurla=>"P", :branchid=>nil, :branchname=>nil, :institutionid => 31, :loanrep=>"45678456784567845678", 
      :loanrepname=>"BIFF LOANREPGUY", :note_rate=>"2.875", :pntsfees=>"3044.14", :broker=>"56789567895678956789", 
      :brokername=>"BIG FANCY BANK CORP.", :ltv=>"22.838", :cltv=>"22.838", :debt_ratio=>"24.991", :comb_ratio=>"27.847", 
      :apcrscore=>"795", :capcrscore=>"786", :penalty=>"2", :loan_prog=>"Conforming 15yr Fixed", :marital=>"1", 
      :maritalc=>"1", :apl_age=>"19560131", :co_apl_age=>"34", :cash_out=>"2", :doc_type=>"2", :amort_term=>"120", 
      :amorttype=>"F", :apprvalue=>"340000", :lender_fee=>"780.58", :broker_fee=>"3570.12", :orig_fee=>"        ", 
      :disc_pnt=>"0", :dpts_dl=>"        ", :houseprp=>"1441.07", :mnthdebt=>"1605.73"
    }
  end

  let(:sample_input) do
    CSV.generate do |csv|
      csv << HEADER_LINE.strip.split(',')
      csv << sample_data.values
    end
  end

  it "should import a loan event for each line of input after the first" do
    input = HEADER_LINE + empty_line(1) + empty_line(2)
    report_date = Array(DateTime.civil(2012, 11, 1))
    initial = LoanComplianceEvent.count
    subject.input_file_import(input, 1, report_date)
    LoanComplianceEvent.count.should == initial+2
  end

  it "do not create a second loan event for a loan that is identical to an existing event" do
    initial = LoanComplianceEvent.count
    input = HEADER_LINE + empty_line(1234567)*2  # 2 identical lines
    report_date = Array(DateTime.civil(2012, 11, 1))
    subject.input_file_import(input, 1, report_date)
    LoanComplianceEvent.count.should == initial+1  # should only import one time
  end

  describe 'columns' do
    before :all do
      LoanComplianceEvent.delete_all
      filename = File.expand_path("./lar_file_sample_scrubbed.csv", File.dirname(__FILE__))
      report_date = Array(DateTime.civil(2012, 11, 1))

      @importer = Compliance::Hmda::LarFileImporter.new
      @importer.input_file_import(File.read(filename), 1, report_date)
      @event = LoanComplianceEvent.last
    end

    subject { @importer }
    let(:event) { @event }

    it { event.actdate.should == Date.new(2012, 11, 26) }
    it { event.action.should == 1 }
    it { event.amort_term.should == 120 }
    it { event.amorttype.should == "F" }
    it { event.apcrscore.should == 795 }
    it { event.apdate.should == Date.new(2012, 8, 30) }
    it { event.apeth.should == 2 }
    it { event.apl_age.should == "19560131" }
    it { event.aplnno.should == "1022358" }
    it { event.appname.should == "ABEL ALEXANDER" }
    it { event.apprvalue.should == 340000 }
    it { event.apptakenby.should == "M" }
    it { event.apr.to_s.should == "3.716" }
    it { event.aprace.should == "5" }
    it { event.apsex.should == 1 }
    it { event.branchid.should == nil }
    it { event.branchname.should == nil }
    it { event.institutionid.should == "31" }
    it { event.broker.should == '56789' * 4 }
    it { event.broker_fee.should == "3570.12" }
    it { event.brokername.should == "BIG FANCY BANK CORP." }
    it { event.capcrscore.should == 786 }
    it { event.capeth.should == 2 }
    it { event.caprace.should == "5" }
    it { event.capsex.should == 2 }
    it { event.cash_out.should == 2 }
    it { event.censustrct.should == 'NA' }
    it { event.channel.should == 2 }
    it { event.cltv.should == "22.84" }
    it { event.cntycode.should == '69' }
    it { event.co_apl_age.should == 34 }
    it { event.comb_ratio.should == "27.847" }
    it { event.createdate.should == Date.new(2012, 8, 28) }
    it { event.debt_ratio.should == "24.991" }
    it { event.denialr1.should == nil }
    it { event.denialr2.should == nil }
    it { event.denialr3.should == nil }
    it { event.disc_pnt.should == 0 }
    it { event.doc_type.should == 2 }
    it { event.dpts_dl.should == nil }
    it { event.finaldate.should == Chronic.parse("9/6/2012 14:37") }
    it { event.hoepa.should == 2 }
    it { event.houseprp.should == "1441.07" }
    it { event.initadjmos.should == nil }
    it { event.lender_fee.should == "780.58" }
    it { event.lienstat.should == 1 }
    it { event.lnamount.should == 78 }
    it { event.lnpurpose.should == 3 }
    it { event.lntype.should == 1 }
    it { event.loan_prog.should == "Conforming 15yr Fixed" }
    it { event.loan_term.should == 120 }
    it { event.loanrep.should == '45678' * 4 }
    it { event.loanrepname.should == "BIFF LOANREPGUY" }
    it { event.lockdate.should == Date.new(2012, 11, 2) }
    it { event.ltv.should == "22.84" }
    it { event.macode.should == 'NA' }
    it { event.marital.should == 1 }
    it { event.maritalc.should == 1 }
    it { event.mnthdebt.should == "1605.73" }
    it { event.note_rate.should == "2.875" }
    it { event.occupancy.should == 1 }
    it { event.occupyurla.should == "P" }
    it { event.orig_fee.should == nil }
    it { event.penalty.should == 2 }
    it { event.pntsfees.should == "3044.14" }
    it { event.preappr.should == 3 }
    it { event.propcity.should == "Somewhere" }
    it { event.propstate.should == "NY" }
    it { event.propstreet.should == "123 Alice Ave" }
    it { event.proptype.should == 1 }
    it { event.propzip.should == "12345" }
    it { event.purchtype.should == nil }
    it { event.qltychk.should == "N" }
    it { event.spread.should == nil }
    it { event.stcode.should == '36' }
    it { event.tincome.should == "69" }
  end

  describe 'data signatures' do
    before do
      LoanComplianceEvent.delete_all
      LoanComplianceEvent.create(aplnno: 1234, original_signature: 'asdfjkl')
    end

    it "should return original signature" do
      subject.send(:original_sigs).should == ['asdfjkl']
    end

    it "should return current signature" do
      subject.send(:current_sigs).should == ["10d884358366e3b73180c1a466da84d03a62990f"]
    end

    it "should return set of hash" do
      subject.send(:existing_hashes).should be_kind_of(Set)
    end
  end

  def empty_line(aplnno = "")
    aplnno.to_s + 
      ("," * 15) + '11/23/2012' +
      ("," * 61) + "\n"
  end

  def make_new_loan
    l = Loan.new 
    l.loan_general = loan_general
    l
  end

end
