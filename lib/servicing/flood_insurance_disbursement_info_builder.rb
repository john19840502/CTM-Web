
module Servicing
  class FloodInsuranceDisbursementInfoBuilder < DisbursementInfoBuilderBase

    def initialize(loan, fee_name)
      @sys_fee_name = fee_name
      super(loan)
    end

    def build_info
      return flood_insurance_dummy_card if dummy_flood_card_needed?

      super
    end

    def mapped_type
      type
    end

    def disbursement_name
      'FloodInsurance'
    end

    def hud_line_num
      1007
    end

    def name
      @sys_fee_name.gsub(/\s|\./,'').underscore
    end

    def system_fee_name
      @sys_fee_name
    end

    def escrow_item_type
      "FloodInsurance"
    end

    def type
      'H'
    end

    def qualifier
      loan.is_condo? ? 7 : 2
    end

    def payee_code_prefix
      '9999'
    end

    def payee_code_suffix
      '99993'
    end

    def expiration_date
      date
    end

    def certificate_identifier
      loan.flood_insurance_policy_number.present? ? loan.flood_insurance_policy_number : 999_999_993
    end

    private

    def flood_insurance_dummy_card
      db = Fiserv::EscrowDisbursementInfo.new 'Dummy_Flood_Insurance'
      db.count = 12
      db.months = [ 0, 0, 0, 0 ]
      db.type = mapped_type
      db.amount = 0
      db.type_qualifier = loan.is_condo? ? 7 : 2
      db.certificate_identifier = loan.flood_insurance_policy_number.present? ? loan.flood_insurance_policy_number : 999_999_993
      db.payee_code_prefix      = 9999
      db.payee_code_suffix      = 99993
      db.coverage_amount = nil
      db.coverage_code = ' '
      db
    end

    def dummy_flood_card_needed?
      loan.special_flood_hazard_area_indicator &&
        !loan.hud_lines.any? do |hl| 
          hl.hud_type == 'HUD' && is_flood?(hl) && hl.monthly_amount.to_f > 0
      end
    end

    def is_flood?(hl)
      if loan.trid_loan?
        hl.system_fee_name == system_fee_name
      else
        hl.line_num.eql?(1007) || 
          (hl.line_num.in?([1008, 1009]) && hl.user_defined_fee_name.try(:downcase) =~ /flood/)
      end
    end


  end
end
