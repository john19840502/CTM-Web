require 'fiserv/escrow_disbursement_info'

module Servicing
  class CountyTaxDisbursementInfoBuilder < DisbursementInfoBuilderBase

    def disbursement_name
      'CountyPropertyTax'
    end

    def hud_line_num
      1005
    end

    def system_fee_name
      "County Taxes"
    end

    def escrow_item_type
      "CountyPropertyTax"
    end

    def type
      'T'
    end

    def qualifier
      0
    end
  end
end
