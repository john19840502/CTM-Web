
module Servicing
  class EarthquakeInsuranceDisbursementInfoBuilder < DisbursementInfoBuilderBase

    def disbursement_name
      'Earthquake'
    end

    def system_fee_name
      "Earthquake Insurance"
    end

    # only used for trid, but the dummy stuff requires we specify?
    def hud_line_num
      1234
    end

    def escrow_item_type
      "EarthquakeInsurance"
    end

    def type
      'H'
    end

    def qualifier
      4
    end

    def expiration_date
      date
    end

  end
end
