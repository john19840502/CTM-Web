
module Servicing
  class HazardInsuranceDisbursementInfoBuilder < DisbursementInfoBuilderBase

    def build_info
      cards = []

      if loan.lender_paid_mi && hud_line.nil?
        cards << hazard_insurance_dummy_card 
      else
        cards << super
      end

      if loan.is_condo?
        cards << hazard_insurance_dummy_card if dummy_hazard_card_needed?
        cards << h6_dummy_card
      end

      cards
    end

    def h6_dummy_card
      db = Fiserv::EscrowDisbursementInfo.new 'Dummy_Hazard_Insurance'
      db.count = '12'
      # if dummy_hazard_card_needed?
        db.type = '2'
      # else
      #   db.type = 'H'
      # end
      db.type_qualifier = '6'
      db.certificate_identifier = '999999993'
      db.payee_code_prefix, db.payee_code_suffix = [ '9999', '99993' ]
      db
    end

    def hazard_insurance_dummy_card
      db                          = Fiserv::EscrowDisbursementInfo.new 'hazard_insurance'
      db.count                    = 12
      db.type                     = loan.is_condo? ? '1' : '2'
      db.type_qualifier           = loan.is_condo? ? '7' : '0'
      db.certificate_identifier   = '999999993'
      db.payee_code_prefix        = '9999'
      db.payee_code_suffix        = '99993'
      db 
    end

    def disbursement_name
      'HazardInsurance'
    end

    def hud_line_num
      1002
    end

    def system_fee_name
      "Homeowners Insurance"
    end

    def escrow_item_type
      "HazardInsurance"
    end

    def type
      loan.is_condo? ? 'Z' : 'H'
    end

    def qualifier
      loan.is_condo? ? 7 : 0
    end

    def certificate_identifier
      if loan.is_condo? 
        loan.hazard_insurance_policy_number.present? ? loan.hazard_insurance_policy_number : 999_999_993
      else
        loan.hazard_insurance_policy_number
      end
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

    private

    def dummy_hazard_card_needed?
      !loan.hud_lines.any? do |hl| 
        hl.hud_type == 'HUD' && is_hazard?(hl) && hl.monthly_amount.to_f > 0
      end
    end

    def is_hazard?(hl)
      hl.system_fee_name == system_fee_name
    end

  end
end
