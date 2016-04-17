
module Servicing
  class HurricaneInsuranceDisbursementInfoBuilder < DisbursementInfoBuilderBase

    def disbursement_name
      'StormInsurance'
    end

    # only used for trid, but the dummy stuff requires we specify?
    def hud_line_num
      1234
    end

    def system_fee_name
      "Hurricane Insurance"
    end

    def escrow_item_type
      "StormInsurance"
    end

    def type
      'H'
    end

    def qualifier
      loan.is_condo? ? 8 : 3
    end

    def expiration_date
      date
    end

  end
end
