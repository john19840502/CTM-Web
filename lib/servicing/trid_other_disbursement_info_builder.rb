
module Servicing
  class TridOtherDisbursementInfoBuilder < DisbursementInfoBuilderBase

    def disbursement_name
      'Other'
    end

    # only used for trid, but the dummy stuff requires we specify?
    def hud_line_num
      1234
    end

    def system_fee_name
      'Other Insurance'
    end

    def escrow_item_type
      'Other'
    end

    def name
      'insurance'
    end

    def type
      loan.is_condo? ? 'Z' : 'H'
    end

    def qualifier
      0
    end

    def expiration_date
      date
    end

  end
end
