
require 'fiserv/escrow_disbursement_info'

module Servicing
  class AnnualAssessmentDisbursementInfoBuilder < DisbursementInfoBuilderBase

    def name
      'annual_assessments'
    end

    def disbursement_name
      'Assessment'
    end

    def hud_line_num
      1006
    end

    def system_fee_name
      "Annual Assessments"
    end

    def escrow_item_type
      "TownPropertyTax"
    end

    def type
      'T'
    end

    def qualifier
      3
    end
  end
end
