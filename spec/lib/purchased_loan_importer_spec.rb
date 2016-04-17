require 'spec_helper'
require 'purchased_loan_importer'

describe Compliance::Hmda::PurchasedLoanImporter do

  subject { Compliance::Hmda::PurchasedLoanImporter.new }

  PURCHASED_HEADER = "CPI Number,Basis Code,Original Balance,Current Balance,Original Rate,Current Rate,Index,Term,Amortization Term,IOTerm,Original P and I,Current P and I,ESCROW PAYMENT,Origination Year,Origination Month,Origination Day,First Pay Date Year,First Pay Date Month,First Pay Date Day,Maturity Year,Maturity Month,Maturity Day,Next Due Year,Next Due Month,Next Due Day,Times Deliquent,Property Value,Purchase Price,First Name,Last Name,Name,Social Security,Address,City,State,Zipcode,County,Loan Purpose,Property Type,Number of Units,Occupancy Code,Documentation ,Credit Grade,CREDIT SCORE,Pmi Code,PMI Level,Group Number,LTV Ratio,CLTV Ratio,Age,Months to Expect Maturity,Months to Stated Maturity,Margin,First Cap,ATA Max,Life Cap,Life Floor,Orig Rate Chg Year,Orig Rate Chg Month,Orig Rate Chg Day,Interest Rate Chg Year,Interest Rate Chg Month,Interest Rate Chg Day,Months to Roll,Initial Rate Frequency,Rate Adjustment Frequency,Convertible,Mi Certificate ID,MERS_FLAG,MERS_Number,Back End Ratio,Front End Ratio,Self Employed,Deal Year,Deal Abbreviation,Product Code,Market_Type_Description,Asset Verification Flag,Appraisal Type,Leasehold Flag,Buydown Code,NPCScrubbed,CashOutPurpScrubbed,IndexValueValidated,CustodyDataValidated,WholsaleFullDocSIsAvalida,PointsAndFeesTestYN,FirstTimeHomebuyer,AppraisalType,CurrentActualUPB,ActualNextDueDate,Income in Thousands,CoBorrower Name,CoBorrower SS,RESERVES,ASSETS_AFTER_CLOSE,TOT_VERIFIED_ASSETS,CURRENT FICO,OTHER_FIN,ARM LOOKBACK,FOREIGN_MAIL_ADDR,PRM_BORR_MAIL_ADDR,PRM_BORR_MAIL_CTY_STE_ZIP,LOANTYPE,PROPTYPE,PURPOSE,OCCUPNCY,PREAPPRV,DISPDATE,APPETNIC,CPPETNIC,APPRACE1,APPRACE2,APPRACE3,APPRACE4,APPRACE5,CPPRACE1,CPPRACE2,CPPRACE3,CPPRACE4,CPPRACE5,APPGENDR,CPPGENDR,ANNINC,HOEPA_ST,Lien_st,match\n"
  
  let(:sample_data) do
    { :cpi_number=>"111111", :basis_code=>"30", :original_balance=>"12,345.00", :current_balance=>"12,345.00", :original_rate=>"1.23", :current_rate=>"1.23", 
      :index=>"RT", :term=>"360", :amortization_term=>"360", :ioterm=>"0", :original_p_and_i=>"123.45", :current_p_and_i=>"123.45", :escrow_payment=>"123.45", 
      :origination_year=>"2013", :origination_month=>"09", :origination_day=>"27", :first_pay_date_year=>"2013", :first_pay_date_month=>"09", 
      :first_pay_date_day=>"27", :maturity_year=>"2013", :maturity_month=>"09", :maturity_day=>"27", :next_due_year=>"2013", :next_due_month=>"09", 
      :next_due_day=>"27", :times_deliquent=>"0", :property_value=>"230,000.00", :purchase_price=>"230,00.00", :first_name=>"John", :last_name=>"Doe", :name=>"John Doe", 
      :social_security=>"123-45-6789", :address=>"123 Main St.", :city=>"Ann Arbor", :state=>"MI", :zipcode=>"48105", :county=>"Washtenaw", :loan_purpose=>"1", 
      :property_type=>"1", :number_of_units=>"1", :occupancy_code=>"1", :documentation=>"Z", :credit_grade=>"A", :credit_score=>"723", :pmi_code=>"0", 
      :pmi_level=>"30", :group_number=>"1", :ltv_ratio=>"89.99", :cltv_ratio=>"89.99", :age=>"1", :months_to_expect_maturity=>"359", 
      :months_to_stated_maturity=>"359", :margin=>"", :first_cap=>"", :ata_max=>"", :life_cap=>"", :life_floor=>"",:org_rate_chg_year=>"", 
      :org_rate_chg_month=>"", :org_rate_chg_day=>"", :interest_rate_chg_year=>"", :interest_rate_chg_month=>"", 
      :interest_rate_chg_day=>"", :months_to_roll=>"", :initial_rate_frequency=>"", :rate_adjustment_frequency=>"", :convertible=>"N", 
      :channels=>"N", :mi_certificate_id=>"1234567890", :mers_flag=>"N", :mers_number=>"1234567890", :back_end_ratio=>"12.34", :front_end_ratio=>"12.34", 
      :self_employed=>"N", :deal_year=>"2013", :deal_abbreviation=>"CRA47", :product_code=>"212", :market_type_description=>"30 YR FNMA CONF", 
      :asset_verification_flag=>"Y", :appraisal_type=>"04", :leasehold_flag=>"N", :buydown_code=>"1", :npcscrubbed=>"X", 
      :cashoutpurpscrubbed=>"X", :indexvaluevalidated=>"X", :custodydatavalidated=>"Y", :wholesalfulldocsisavalida=>"Y", 
      :pointsandfeestestyn=>"X", :firsttimehomebuyer=>"Y", :appraisaltype=>"w/e", :currentactualupb=>"123,456.78", :actualnextduedate=>"201309027", 
      :income_in_thousands=>"47", :coborrower_name=>"", :coborrower_ss => "", :reserves=>"", :assets_after_close=>"", :tot_verified_assets=>"", 
      :current_fico=>"778", :other_fin=>"", :arm_lookback=>"", :foreign_mail_addr=>"N", :prm_borr_mail_addr=>"123 Main St.", 
      :prm_borr_mail_cty_ste_zip=>"Ann Arbor MI 48105", :loantype=>"1", :proptype=>"1", :purpose=>"1", :occupncy=>"1", :preapprv=>"1", :dispdate=>"07/01/2013", 
      :appetnic=>"1", :cppetnic=>"1", :apprace1=>"1", :apprace2=>"", :apprace3=>"", :apprace4=>"", :apprace5=>"", :cpprace1=>"1", 
      :cpprace2=>"", :cpprace3=>"", :cpprace4=>"", :cpprace5=>"", :appgendr=>"1", :cppgendr=>"2", :anninc=>"23", :hoepa_st=>"1", :lien_st=>"1", 
      :match=>"1"
    }
  end

  let(:sample_input) do
    CSV.generate do |csv|
      csv << PURCHASED_HEADER.strip.split(',')
      csv << sample_data.values
    end
  end

  it "should import a purchased loan for each line of input after the first" do
    input = PURCHASED_HEADER + empty_line(1) + empty_line(2)
    report_date = "08/01/2013"
    initial = PurchasedLoan.count
    subject.import_file input, report_date
    PurchasedLoan.count.should == initial+2
  end

  it "do not create a second loan event for a loan that is identical to an existing event" do
    initial = PurchasedLoan.count
    input = PURCHASED_HEADER + empty_line(1234567)*2  # 2 identical lines
    report_date = "08/01/2013"
    subject.import_file input, report_date
    PurchasedLoan.count.should == initial+1  # should only import one time
  end

  describe 'columns' do
    before :all do
      PurchasedLoan.delete_all
      report_date = "08/01/2013"
      filename = File.expand_path("./purchased_loans_scrubbed.csv", File.dirname(__FILE__))
      @importer = Compliance::Hmda::PurchasedLoanImporter.new
      @importer.import_file File.read(filename), report_date
      @ploan = PurchasedLoan.last
    end

    subject { @importer }
    let(:ploan) { @ploan }

    it { ploan.cpi_number.should == "9876543219" }
    it { ploan.basis_code.should == 30 }
    it { ploan.original_balance.should == "184,000.00" }
    it { ploan.current_balance.should == "183,728.93" }
    it { ploan.original_rate.should == "3.875" }
    it { ploan.current_rate.should == "3.875" }
    it { ploan.index.should == "RT" }
    it { ploan.term.should == 360 }
    it { ploan.amortization_term.should == 360 }
    it { ploan.ioterm.should == 0 }
    it { ploan.original_p_and_i.should == "865.24" }
    it { ploan.current_p_and_i.should == "865.24" }
    it { ploan.escrow_payment.should == "235.46" }
    it { ploan.origination_year.should == 2012 }
    it { ploan.origination_month.should == 7 }
    it { ploan.origination_day.should == 18 }
    it { ploan.first_pay_date_year.should == 2012 }
    it { ploan.first_pay_date_month.should == 9 }
    it { ploan.first_pay_date_day.should == 1 }
    it { ploan.maturity_year.should == 2042 }
    it { ploan.maturity_month.should == 8 }
    it { ploan.maturity_day.should == 1 }
    it { ploan.next_due_year.should == 2012 }
    it { ploan.next_due_month.should == 10 }
    it { ploan.next_due_day.should == 1 }
    it { ploan.times_deliquent.should == 0 }
    it { ploan.property_value.should == "230,000.00" }
    it { ploan.purchase_price.should == "230,000.00" }
    it { ploan.first_name.should == "GEORGE" }
    it { ploan.last_name.should == "JONES" }
    it { ploan.name.should == "JONES GEORGE" }
    it { ploan.social_security.should == "444-88-9999" }
    it { ploan.address.should == "123 NASHVILLE DR" }
    it { ploan.city.should == "NASHVILLE" }
    it { ploan.state.should == "TN" }
    it { ploan.zipcode.should == "37201" }
    it { ploan.county.should == "DAVIDSON" }
    it { ploan.loan_purpose.should == 1 }
    it { ploan.property_type.should == 6 }
    it { ploan.number_of_units.should == 1 }
    it { ploan.occupancy_code.should == 1 }
    it { ploan.documentation.should == "Z" }
    it { ploan.credit_grade.should == nil }
    it { ploan.credit_score.should == 778 }
    it { ploan.pmi_code.should == 0 }
    it { ploan.pmi_level.should == nil }
    it { ploan.group_number.should == 1 }
    it { ploan.ltv_ratio.should == "80" }
    it { ploan.cltv_ratio.should == "80" }
    it { ploan.age.should == 1 }
    it { ploan.months_to_expect_maturity.should == 359 }
    it { ploan.months_to_stated_maturity.should == 359 }
    it { ploan.margin.should == nil }
    it { ploan.first_cap.should == nil }
    it { ploan.ata_max.should == nil }
    it { ploan.life_cap.should == nil }
    it { ploan.life_floor.should == nil }
    it { ploan.orig_rate_chg_year.should == nil }
    it { ploan.orig_rate_chg_month.should == nil }
    it { ploan.orig_rate_chg_day.should == nil }
    it { ploan.interest_rate_chg_year.should == nil }
    it { ploan.interest_rate_chg_month.should == nil }
    it { ploan.interest_rate_chg_day.should == nil }
    it { ploan.months_to_roll.should == nil }
    it { ploan.initial_rate_frequency.should == nil }
    it { ploan.rate_adjustment_frequency.should == nil }
    it { ploan.convertible.should == nil }
    it { ploan.channels.should == "N" }
    it { ploan.mi_certificate_id.should == nil }
    it { ploan.mers_flag.should == nil }
    it { ploan.mers_number.should == nil }
    it { ploan.back_end_ratio.should == "42.583" }
    it { ploan.front_end_ratio.should == nil }
    it { ploan.self_employed.should == "N" }
    it { ploan.deal_year.should == 2012 }
    it { ploan.deal_abbreviation.should == "CRA47" }
    it { ploan.product_code.should == 212 }
    it { ploan.market_type_description.should == "30 YR FNMA CONF" }
    it { ploan.asset_verification_flag.should == "Y" }
    it { ploan.appraisal_type.should == 4 }
    it { ploan.leasehold_flag.should == "N" }
    it { ploan.buydown_code.should == 1 }
    it { ploan.npcscrubbed.should == "X" }
    it { ploan.cashoutpurpscrubbed.should == "X" }
    it { ploan.indexvaluevalidated.should == "X" }
    it { ploan.custodydatavalidated.should == "Y" }
    it { ploan.wholsalefulldocsisavalida.should == "Y" }
    it { ploan.pointsandfeestestyn.should == "X" }
    it { ploan.firsttimehomebuyer.should == "Y" }
    it { ploan.appraisaltype.should == nil }
    it { ploan.currentactualupb.should == "183,728.93" }
    it { ploan.actualnextduedate.should == "20121001" }
    it { ploan.income_in_thousands.should == 47 }
    it { ploan.coborrower_name.should == nil }
    it { ploan.coborrower_ss.should == nil }
    it { ploan.reserves.should == nil }
    it { ploan.assets_after_close.should == nil }
    it { ploan.tot_verified_assets.should == nil }
    it { ploan.current_fico.should == 778 }
    it { ploan.other_fin.should == nil }
    it { ploan.arm_lookback.should == nil }
    it { ploan.foreign_mail_addr.should == "N" }
    it { ploan.prm_borr_mail_addr.should == "   1437 N ARTESIAN AVE UNIT 2" }
    it { ploan.prm_borr_mail_cty_ste_zip.should == "CHICAGO IL 60622" }
    it { ploan.loantype.should == 1 }
    it { ploan.proptype.should == 1 }
    it { ploan.purpose.should == 1 }
    it { ploan.occupncy.should == 1 }
    it { ploan.preapprv.should == 3 }
    it { ploan.dispdate.should == "08/01/2013" }
    it { ploan.appetnic.should == 2 }
    it { ploan.cppetnic.should == 5 }
    it { ploan.apprace1.should == 5 }
    it { ploan.apprace2.should == nil }
    it { ploan.apprace3.should == nil }
    it { ploan.apprace4.should == nil }
    it { ploan.apprace5.should == nil }
    it { ploan.cpprace1.should == 8 }
    it { ploan.cpprace2.should == nil }
    it { ploan.cpprace3.should == nil }
    it { ploan.cpprace4.should == nil }
    it { ploan.cpprace5.should == nil }
    it { ploan.appgendr.should == 1 }
    it { ploan.cppgendr.should == 5 }
    it { ploan.anninc.should == 47 }
    it { ploan.hoepa_st.should == 2 }
    it { ploan.lien_st.should == 1 }
    it { ploan.match.should == 1 }
  end

  def empty_line(cpi_number = "")
    cpi_number.to_s + 
      ("," * 12) + '1' +
      ("," * 114) + "\n"
  end

end
