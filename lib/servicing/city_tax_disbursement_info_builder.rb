require 'fiserv/escrow_disbursement_info'

module Servicing
  class CityTaxDisbursementInfoBuilder < DisbursementInfoBuilderBase

    def disbursement_name
      'CityPropertyTax'
    end

    def hud_line_num
      1004
    end

    def system_fee_name
      'City Taxes'
    end

    def escrow_item_type
      'CityPropertyTax'
    end

    def type
      'T'
    end

    def qualifier
      1
    end
  end
end
