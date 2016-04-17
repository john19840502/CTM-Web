
module Servicing
  class VillageTaxDisbursementInfoBuilder < DisbursementInfoBuilderBase

    def disbursement_name
      'TownshipPropertyTax'
    end

    # only used for trid, but the dummy stuff requires we specify?
    def hud_line_num
      1234
    end

    def name
      'village'
    end

    def system_fee_name
      "Village Taxes"
    end

    def escrow_item_type
      "TownshipPropertyTax"
    end

    def type
      'T'
    end

    def qualifier
      2
    end

  end
end
