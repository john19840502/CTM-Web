require "spec_helper"

RSpec.describe Smds::FhlbCsvBuilder do

  let(:loan) { Smds::FhlbLoan.new }

  it "should have a loan number field" do
    loan.SellerLoanIdentifier = 123
    field = subject.fields.find{ |f| f.name == "SellerLoanIdentifier"}
    expect(field.value_for(loan)).to eq 123
  end

  it "documentation type" do
    field = find_field "Documentation Type"
    expect(field.value_for(loan)).to eq "6"
  end

  it "Rent Plus Utilities - Unit 1" do
    field = find_field "Rent Plus Utilities - Unit 1"
    expect(field.value_for(loan)).to eq "0"
  end

  it "Rent Plus Utilities - Unit 2" do
    field = find_field "Rent Plus Utilities - Unit 2"
    expect(field.value_for(loan)).to eq "0"
  end

  it "Rent Plus Utilities - Unit 3" do
    field = find_field "Rent Plus Utilities - Unit 3"
    expect(field.value_for(loan)).to eq "0"
  end

  it "Rent Plus Utilities - Unit 4" do
    field = find_field "Rent Plus Utilities - Unit 4"
    expect(field.value_for(loan)).to eq "0"
  end

  it "Unit - Owner Occupied - Unit 1" do
    field = find_field "Unit - Owner Occupied - Unit 1"
    expect(field.value_for(loan)).to eq "1"
  end

  [2,3,4].each do |n|
    it "Unit - Owner Occupied - Unit #{n}" do
      field = find_field "Unit - Owner Occupied - Unit #{n}"
      expect(field.value_for(loan)).to eq "0"
    end
  end

  it "Anti-Predatory Lending Category" do
    field = find_field "Anti-Predatory Lending Category"
    expect(field.value_for(loan)).to eq "NO"
  end

  it "MH- Prior Occupancy Status" do
    field = find_field "MH- Prior Occupancy Status"
    expect(field.value_for(loan)).to eq nil
  end

  it "MH-Loan-to-Invoice (LTI)" do
    field = find_field "MH-Loan-to-Invoice (LTI)"
    expect(field.value_for(loan)).to eq nil
  end

  it "FIPS State/County Code" do
    loan.FIPSCode = "1234"
    field = find_field "FIPS State/County Code"
    expect(field.value_for(loan)).to eq "01234"
  end

  describe "HPML Flag" do
    it "should be Y for Y" do
      loan.HPMLFlg = "Y"
      field = find_field "Higher Priced Mortgage Loan Status"
      expect(field.value_for(loan)).to eq "Y"
    end

    it "should be N for anything else" do
      field = find_field "Higher Priced Mortgage Loan Status"
      [nil, 'N', '', ' ', 'NA', 'N/A'].each do |v|
        loan.HPMLFlg = v
        expect(field.value_for(loan)).to eq "N"
      end
    end
  end

  it "Fed Fin Stab Plan" do
    field = find_field "Mortgage Acquired using Federal Financial Stability Plan Funds"
    expect(field.value_for(loan)).to eq "N"
  end

  [1,2,3,4].each do |n|
    it "Affordable Category Unit ##{n}" do
      field = find_field "Affordable Category Unit ##{n}"
      expect(field.value_for(loan)).to eq "N"
    end
  end

  it "FHLB AHP Loans" do
    field = find_field "FHLB AHP Loans"
    expect(field.value_for(loan)).to eq "N"
  end

  it "FHLB CICA Loans" do
    field = find_field "FHLB CICA Loans"
    expect(field.value_for(loan)).to eq "N"
  end

  it "CountyName" do
    loan.PropertyCounty = "foo"
    field = find_field "CountyName"
    expect(field.value_for(loan)).to eq "foo"
  end

  it "ManufacturedHomeManufactureYear" do
    field = find_field "ManufacturedHomeManufactureYear"
    expect(field.value_for(loan)).to eq nil
  end

  it "ManufacturedHomeWidthType" do
    field = find_field "ManufacturedHomeWidthType"
    expect(field.value_for(loan)).to eq nil
  end

  it "AssetDocumentationLevelIdentifier" do
    field = find_field "AssetDocumentationLevelIdentifier"
    expect(field.value_for(loan)).to eq "Y"
  end

  describe "EmploymentBorrowerSelfEmployedIndicator" do
    before do
      loan.Brw1SelfEmpFlg = 'N'
      loan.Brw2SelfEmpFlg = 'N'
      loan.Brw3SelfEmpFlg = 'N'
      loan.Brw4SelfEmpFlg = 'N'
    end
    let(:field) { find_field "EmploymentBorrowerSelfEmployedIndicator" }

    it "should be N when none of the borrowers are self employed" do
      expect(field.value_for(loan)).to eq "N"
    end

    [1,2,3,4].each do |n|
      it "should be Y when Borrower #{n} is self employed" do
        loan.send "Brw#{n}SelfEmpFlg=", "Y"
        expect(field.value_for(loan)).to eq "Y"
      end
    end
  end

  it "HMDARateSpreadPercent" do
    loan.APRSprdPct = 1.23
    field = find_field "HMDARateSpreadPercent"
    expect(field.value_for(loan)).to eq 1.23
  end

  describe "MICertificateIdentifier" do
    let(:field) { find_field "MICertificateIdentifier" }

    ["FHA", "VA", "FarmersHomeAdministration" ].each do |type|
      context "When the mortgage type is #{type}" do
        before { loan.stub_chain(:master_loan, :mortgage_type).and_return(type)}
        it "should be the agency case identifier" do
          loan.stub_chain(:master_loan, :agency_case_identifier).and_return("abc")
          expect(field.value_for(loan)).to eq nil
        end

        it "should be blank if the case id is NA or N/A" do
          ["NA", "N/A"].each do |v|
            loan.stub_chain(:master_loan, :agency_case_identifier).and_return(v)
            expect(field.value_for(loan)).to eq nil
          end
        end
      end
    end

    context "when the loan is conventional" do
      before { loan.stub_chain(:master_loan, :mortgage_type).and_return("Conventional") }
      it "should come from th smds cert nbr" do
        loan.MICertNbr = "xyz"
        expect(field.value_for(loan)).to eq nil
      end

      it "should be blank if the case id is NA or N/A" do
        ["NA", "N/A"].each do |v|
          loan.MICertNbr = v
          expect(field.value_for(loan)).to eq nil
        end
      end
    end
  end

  describe "AutomatedUnderwritingSystemType" do
    let(:field) { find_field "AutomatedUnderwritingSystemType" }
    it "should be DesktopUnderwriter for DU" do
      loan.AUSType = "DU"
      expect(field.value_for(loan)).to eq "DesktopUnderwriter"
    end
    it "should be LoanProspector for LP" do
      loan.AUSType = "LP"
      expect(field.value_for(loan)).to eq "LoanProspector"
    end
    it "should be Other for anything else" do
      loan.AUSType = "foo"
      expect(field.value_for(loan)).to eq "Other"
    end
  end

  describe "make_csv" do
    let(:loans) { [] }
    let(:csv) { subject.make_csv loans }
    let(:rows) { rows = csv.split "\n" }

    it "should make a header row with the names of all the fields" do
      header = rows[0]
      subject.fields.each do |f|
        expect(header).to include f.name
      end
    end

    it "should make a row for each loan" do
      loans << Smds::FhlbLoan.new.tap { |l| l.SellerLoanIdentifier = 123 }
      loans << Smds::FhlbLoan.new.tap { |l| l.SellerLoanIdentifier = 456 }
      expect(rows[1]).to match /123/
      expect(rows[2]).to match /456/
    end
  end

  describe Smds::FhlbCsvBuilder::Field do
    it "should use nil instead of blank values" do
      [nil, '', ' '].each do |v|
        f = Smds::FhlbCsvBuilder::Field.new('foo') { |l| v }
        expect(f.value_for(loan)).to eq nil
      end
    end
  end

  def find_field name
    f = subject.fields.find{ |f| f.name == name }
    raise "could not find field named #{name}" unless f
    f
  end
end
