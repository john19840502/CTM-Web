class BuildDataCompare
  include ServiceObject

  attr_accessor :loan

  def initialize loan
    self.loan = loan
  end

  def call
    DataCompare.new(loan).tap do |dc|
      dc.fields = [ 
        amortization, applicants, arm_index, base_loan_amount, box_a_discount, escrow_waiver, 
        estimated_property_value, fha_mip, interest_rate, lender_nmls, loan_product,
        loan_purpose_type, loan_term, loan_type, lpmi, ltv, mi, premium_pricing_amount, 
        property_address, sales_price, total_loan_amount, usda_gfee, va_funding_fee,
      ] 
    end
  end

  def amortization
    Field.new("Amortization", 
              lld.try(:loan_amortization_term_months),
              loan.mortgage_term.try(:loan_amortization_term_months))
  end

  def applicants
    borr = [lld.try(:borrower_first_name), lld.try(:borrower_last_name)].join " "
    coborr = [lld.try(:coborrower_first_name), lld.try(:coborrower_last_name)].join " "
    lock = [borr, coborr].reject(&:blank?).join ", "

    f1003 = loan.borrowers.select {|b| [ "BRW1", "BRW2", "BRW3", "BRW4" ].include? b.borrower_id }.
      map(&:first_last_name).reject(&:empty?).join ", "

    Field.new "Applicants", lock, f1003
  end

  def arm_index
    Field.new "ARM Index", :not_applicable, loan.arm.try(:index_current_value_percent)
  end

  def base_loan_amount
    Field.new "Base Loan Amount", :not_applicable, loan.mortgage_term.try(:base_loan_amount)
  end

  def box_a_discount
    net_price = loan.lock_price.try(:net_price)
    if net_price && net_price < 100
      discount = three_decimals(100.0 - net_price)
    else
      discount = ""
    end
    Field.new "Box A Discount", discount, :not_applicable
  end

  def escrow_waiver
    lock = yesno lld.try(:escrow_waiver_indicator)
    f1003 = loan.loan_feature.try(:escrow_waiver_indicator) ? "Yes" : "No"
    Field.new "Escrow Waiver", lock, f1003
  end

  def estimated_property_value
    estimated = loan.transmittal_datum.try(:property_estimated_value_amount)
    actual = loan.transmittal_datum.try(:property_appraised_value_amount)
    f1003 = if estimated
              ValueWithDisplay.new estimated, "Estimated #{estimated}"
            elsif actual
              ValueWithDisplay.new actual, "Actual #{actual}"
            end

    Field.new "Estimated Property Value", lld.try(:property_appraised_value_amount), f1003
  end

  def fha_mip
    Field.new "FHA MIP", :not_applicable, loan.fha_loan.try(:upfront_mi_premium_percent)
  end

  def interest_rate
    Field.new "Interest Rate", loan.lock_price.try(:final_note_rate), loan.mortgage_term.try(:requested_interest_rate_percent)
  end

  def lender_nmls
    Field.new "Lender NMLS", :not_applicable, loan.interviewer.try(:individual_nmls_id)
  end

  def loan_product
    Field.new "Loan Product", loan.lock_price.try(:product_code), loan_product_by_status
  end

  def loan_purpose_type
    Field.new "Loan Purpose Type", lld.try(:loan_purpose_type), loan.loan_purpose.try(:loan_type)
  end

  def loan_term
    Field.new "Loan Term", lld.try(:maturity_term_months), loan.mortgage_term.try(:loan_amortization_term_months)
  end

  def loan_type
    Field.new "Loan Type", translate_lock_loan_type, loan.mortgage_term.try(:mortgage_type)
  end

  def lpmi
    Field.new "LPMI", yesno(lld.try(:lender_paid_mi)), yesno(loan.mi_datum.try(:mi_program_1003) == 1)
  end

  def ltv
    Field.new "LTV", three_decimals(lld.try(:ltv)), three_decimals(loan.ltv)
  end

  def mi
    Field.new "MI", yesno(lld.try(:mi_indicator)), yesno(loan.mi_datum.try(:mi_program_1003).present?)
  end

  def premium_pricing_amount
    net_price = loan.lock_price.try(:net_price)
    if net_price && net_price > 100
      amt = three_decimals(100 - net_price)
    else
      amt = ""
    end
    Field.new "Premium Pricing Amount", amt, :not_applicable
  end

  def property_address
    if lld.nil?
      lock = nil
    else
      lock = format_address lld.property_street_address_number, lld.property_street_address_name, 
        lld.property_street_address_unit, lld.property_city, lld.property_state, 
        lld.property_postal_code
    end

    p = loan.property
    if p.nil?
      f1003 = nil
    else
      f1003 = format_address p.street_number, p.street_name, p.street_unit, p.city, p.state, p.zip
    end
    Field.new "Property Address", lock, f1003
  end

  def sales_price
    Field.new "Sales Price", refinance_zero{lld.try(:purchase_price_amount)}, refinance_zero{loan.transaction_detail.try(:purchase_price_amount)}
  end

  def total_loan_amount
    Field.new "Total Loan Amount", lld.try(:total_loan_amt), loan.mortgage_term.try(:borrower_requested_loan_amount)
  end

  def usda_gfee
    Field.new "USDA Gfee", :not_applicable, loan.transaction_detail.try(:mi_and_funding_fee_total_amount)
  end

  def va_funding_fee
    Field.new "VA Funding Fee", :not_applicable, loan.transaction_detail.try(:mi_and_funding_fee_financed_amount)
  end

  private

  def refinance_zero
    return 0 if is_refinance?
    yield
  end

  def is_refinance?
    loan.loan_type == "Refinance"
  end

  def loan_product_by_status
    case loan.loan_general.try(:additional_loan_datum).try(:pipeline_loan_status_description)
    when "New", "File Received", "U/W Received", "U/W Submitted"
      loan.loan_general.gfe_loan_datum.try(:loan_program)
    else
      loan.loan_general.try(:underwriting_datum).try(:product_code)
    end
  end

  def lld
    loan.lock_loan_datum
  end

  def three_decimals value
    return nil if value.nil?
    "%.3f" % value
  end

  def yesno value
    return nil if value.nil?
    value ? "Yes" : "No"
  end

  def format_address *args
    args.reject(&:blank?).join " "
  end

  def translate_lock_loan_type
    thing = loan.lock_price.try(:product_code)
    case thing
    when "FHA30 IHCDA IN NH", "FHA30 IHDA IL SM", "FHA30STR", "FHA15FXD", "FHA30FXD" then "FHA"
    when "C10/1ARM LIB HIBAL", "C10/1ARM LIB RP", "C10/1ARM LIBOR", "C15FXD", "C15FXD FR",
         "C15FXD HIBAL", "C15FXD RP", "C15FXD RP CD", "C20FXD", "C20FXD FR", "C20FXD HIBAL",
         "C20FXD RP", "C30FXD", "C30FXD FR", "C30FXD HIBAL", "C30FXD HP", "C30FXD MCM", "C30FXD RP",
         "C30FXD RP CD", "C30FXD TEST", "C5/1ARM LIB HIBAL", "C5/1ARM LIB RP", "C5/1ARM LIB",
         "C7/1ARM LIB HIBAL", "C7/1ARM LIB RP", "C7/1ARM LIB", "J15FXD", "J30FXD", "J5/1ARM LIB",
         "J7/1ARM LIB", "J10/1ARM LIB", "TEST J15FXD", "TEST J30FXD"
      then "Conventional"
    when "USDA30FXD" then "USDA"
    when "VA15FXD", "VA30FXD", "VA30IRRL" then "VA"
    else thing
    end
  end


  class DataCompare
    attr_accessor :fields

    def initialize loan
      @loan = loan
      self.fields = []
    end

    def errors
      return []  #apparently they don't care about errors now I guess?  CTMWEB-4553

      return [] unless @loan.is_locked?
      stuff = fields.map(&:error).compact.map do |e|
        { rule_id: Decisions::Flow::DATA_COMPARE_RULE_ID, text: e }
      end
      AppendValidationWarningHistory.call stuff, @loan.id
    end

    def as_json opts={}
      stuff = super(opts).merge "errors" => errors, "warnings" => [], "conclusion" => conclusion
      stuff.except "loan"
    end

    def conclusion
      # this is so dumb
      return "Pass" if @loan.is_locked?
      # return nil if @loan.is_locked?
      "Not Locked"
    end
  end

  Field = Struct.new(:name, :lock_value, :form_1003_value) do
    def match?
      return true if lock_value == :not_applicable || form_1003_value == :not_applicable

      ValueWithDisplay.from(ignore_case(lock_value)) == ValueWithDisplay.from(ignore_case(form_1003_value))

    end

    def error
      return nil if match?
      "Data Compare: #{name} was '#{lock_value}' at lock and '#{form_1003_value}' on the 1003"
    end

    def as_json(opts=nil)
      overrides = {
        "match" => match?
      }
      overrides["lock_value"] = "N/A" if lock_value == :not_applicable
      overrides["form_1003_value"] = "N/A" if form_1003_value == :not_applicable
      super(opts).merge overrides
    end

    def ignore_case val
      return val.downcase if val.class.eql?(String)
      val 
    end
  end

  ValueWithDisplay = Struct.new :value, :display do
    def ==(other)
      return false unless other.class == self.class
      return false if other.nil?
      value == other.value
    end

    def as_json(opts={})
      display
    end

    def to_s
      display
    end

    def self.from thing
      return thing if thing.is_a? ValueWithDisplay
      new thing, thing.to_s
    end
  end

end
