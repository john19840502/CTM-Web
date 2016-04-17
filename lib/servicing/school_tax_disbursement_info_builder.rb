
module Servicing
  class SchoolTaxDisbursementInfoBuilder < DisbursementInfoBuilderBase

    def disbursement_name
      'DistrictPropertyTax'
    end

    # only used for trid, but the dummy stuff requires we specify?
    def hud_line_num
      1234
    end

    def name
      'school'
    end

    def system_fee_name
      "School Taxes"
    end

    def escrow_item_type
      "DistrictPropertyTax"
    end

    def type
      'T'
    end

    def qualifier
      4
    end

  end
end
