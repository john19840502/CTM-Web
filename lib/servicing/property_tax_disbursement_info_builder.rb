
module Servicing
  class PropertyTaxDisbursementInfoBuilder < DisbursementInfoBuilderBase

    def disbursement_name
      'StatePropertyTax'
    end

    # only used for trid, but the dummy stuff requires we specify?
    def hud_line_num
      1234
    end

    def system_fee_name
      "Property Taxes"
    end

    def escrow_item_type
      "StatePropertyTax"
    end

    def name
      'tax'
    end

    def type
      'T'
    end

    def qualifier
      0
    end

  end
end
