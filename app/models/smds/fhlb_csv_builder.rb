module Smds
  class FhlbCsvBuilder


    def fields
      @fields ||= [
        Field.new("SellerLoanIdentifier") {|loan| loan.SellerLoanIdentifier},
        Field.new("Documentation Type") {|loan| "6" },
        Field.new("Rent Plus Utilities - Unit 1") {|loan| "0" },
        Field.new("Rent Plus Utilities - Unit 2") {|loan| "0" },
        Field.new("Rent Plus Utilities - Unit 3") {|loan| "0" },
        Field.new("Rent Plus Utilities - Unit 4") {|loan| "0" },
        Field.new("Unit - Owner Occupied - Unit 1") {|loan| "1" },
        Field.new("Unit - Owner Occupied - Unit 2") {|loan| "0" },
        Field.new("Unit - Owner Occupied - Unit 3") {|loan| "0" },
        Field.new("Unit - Owner Occupied - Unit 4") {|loan| "0" },
        Field.new("Anti-Predatory Lending Category") {|loan| "NO" },
        Field.new("MH- Prior Occupancy Status") {|loan| "" },
        Field.new("MH-Loan-to-Invoice (LTI)") {|loan| "" },
        Field.new("FIPS State/County Code") do |loan|
          if loan.FIPSCode
            loan.FIPSCode.rjust(5, '0')
          end
        end,
        Field.new("Higher Priced Mortgage Loan Status") do |loan|
          case loan.HPMLFlg
          when "Y" then "Y"
          else "N"
          end
        end,
        Field.new("Mortgage Acquired using Federal Financial Stability Plan Funds") {|loan| "N" },
        Field.new("Affordable Category Unit #1") {|loan| "N" },
        Field.new("Affordable Category Unit #2") {|loan| "N" },
        Field.new("Affordable Category Unit #3") {|loan| "N" },
        Field.new("Affordable Category Unit #4") {|loan| "N" },
        Field.new("FHLB AHP Loans") {|loan| "N" },
        Field.new("FHLB CICA Loans") {|loan| "N" },
        Field.new("CountyName") {|loan| loan.PropertyCounty },
        Field.new("ManufacturedHomeManufactureYear") {|loan| "" },
        Field.new("ManufacturedHomeWidthType") {|loan| "" },
        Field.new("AssetDocumentationLevelIdentifier") {|loan| "Y" },
        Field.new("EmploymentBorrowerSelfEmployedIndicator") do |loan|
          flags = [loan.Brw1SelfEmpFlg, loan.Brw2SelfEmpFlg, 
                   loan.Brw3SelfEmpFlg, loan.Brw4SelfEmpFlg, ]
          flags.any?{ |f| f == "Y" } ? "Y" : "N"
        end,
        Field.new("HMDARateSpreadPercent") {|loan| loan.APRSprdPct },
        Field.new("MICertificateIdentifier") {|loan| nil },
        #Field.new("MICertificateIdentifier") do |loan|
        #  mortgage_type = loan.master_loan.try(:mortgage_type)
        #  if ["FHA", "VA", "FarmersHomeAdministration"].include? mortgage_type
        #    cert = loan.master_loan.try(:agency_case_identifier)
        #  else
        #    cert = loan.MICertNbr
        #  end
        #  blank_if_na cert
        #end,
        Field.new("AutomatedUnderwritingSystemType") do |loan|
          case loan.AUSType
          when "DU" then "DesktopUnderwriter"
          when "LP" then "LoanProspector"
          else "Other"
          end
        end,
      ]
    end

    def blank_if_na cert
      case cert
      when "NA", "N/A" then ""
      else cert
      end
    end


    class Field
      attr_accessor :name, :callback

      def initialize name, &callback
        self.name = name
        self.callback = callback
      end

      def value_for loan
        v = callback.call loan
        return nil if v.blank?
        v
      end
    end



    def make_csv loans
      CSV.generate do |csv|
        csv << fields.map(&:name)

        loans.each do |loan|
          csv << fields.map { |field| field.value_for loan }
        end
      end
    end


  end
end
