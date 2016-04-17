
module Servicing
  class WindInsuranceDisbursementInfoBuilder < DisbursementInfoBuilderBase

    def disbursement_name
      'Wind'
    end

    # only used for trid, but the dummy stuff requires we specify?
    def hud_line_num
      1234
    end

    def system_fee_name
      "Wind Insurance"
    end

    def escrow_item_type
      "WindStormInsurance"
    end

    def type
      'H'
    end

    def qualifier
      loan.is_condo? ? 8 : 3 
    end

    def certificate_identifier
      999_999_993
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

  end
end
