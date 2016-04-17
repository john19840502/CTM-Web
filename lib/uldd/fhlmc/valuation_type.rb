
module Fhlmc
  class ValuationType
    def initialize(loan)
      self.loan = loan
    end

    def valuation_type
      return 'AutomatedValuationModel' if relief_override_applies?

      valuation_from_fieldwork ||
      valuation_from_pvm ||
      valuation_from_relief_loan ||
      'None'
    end

    def avm_model
      return 'HomeValueExplorer' if relief_override_applies?
      return loan.AVMModelName if can_trust_avm_model?
      ''
    end

    def additional_investor_features
      return [ 'H03' ] if relief_override_applies?
      []
    end

    def valuation_form
      mapping = {
        '1004C' => 'ManufacturedHomeAppraisalReport',
        '1004D' => 'AppraisalUpdateAndOrCompletionReport',
        '1004 ' => 'UniformResidentialAppraisalReport',
        '1025'  => 'SmallResidentialIncomePropertyAppraisalReport',
        '1073'  => 'IndividualCondominiumUnitAppraisalReport',
        '1075'  => 'ExteriorOnlyInspectionIndividualCondominiumUnitAppraisalReport',
        '2000 ' => 'OneUnitResidentialAppraisalFieldReviewReport',
        '2000A' => 'TwoToFourUnitResidentialAppraisal',
        '2055'  => 'ExteriorOnlyInspectionResidentialAppraisalReport',
        '2075'  => 'DesktopUnderwriterPropertyInspectionReport',
      }
      mapping.each do |number, name|
        return name if loan.FieldworkObtained.start_with? "Form " + number
      end
      ''
    end

    def valuation_other_description
      return 'FieldReview' if valuation_type == 'Other'
      ''
    end

    private
    attr_accessor :loan

     def valuation_from_relief_loan
      return 'AutomatedValuationModel' if relief_loan?
      nil
    end

    def valuation_from_pvm
      return nil if fieldwork_pvm_mismatch?
      return nil if [nil, 'NA', '', 'None'].include?(loan.PropertyValMethod)
      loan.PropertyValMethod
    end

    def valuation_from_fieldwork
      return 'DriveBy' if fieldwork_starts_with?('1075', '2055', '2075')
      return 'FullAppraisal' if fieldwork_starts_with?('1004 ', '1004C', '1004D', '1025', '1073')
      return 'Other' if fieldwork_starts_with?('2000')
      return 'Other' if loan.FieldworkObtained == 'Other' && !has_notable_property_val_method?
      return '' if fieldwork_starts_with?('26-1805', '26-8712')
      nil
    end

    def fieldwork_starts_with?(*form_numbers)
      form_numbers.any? do |num|
        loan.FieldworkObtained.to_s.start_with?("Form " + num)
      end
    end

    def has_notable_property_val_method?
      ['AutomatedValuationModel', 'DesktopAppraisal'].include?(loan.PropertyValMethod)
    end

    def relief_override_applies?
      relief_loan? && (fieldwork_and_pvm_missing? || fieldwork_pvm_mismatch?)
    end

    def relief_loan?
      loan.ProductCode.to_s.end_with?('FR')
    end

    def can_trust_avm_model?
      valuation_from_fieldwork == nil &&
        loan.PropertyValMethod == 'AutomatedValuationModel' &&
        loan.AVMModelName == 'HomeValueExplorer'
    end

    def fieldwork_pvm_mismatch?
      loan.FieldworkObtained == 'No appraisal/inspection obtained' &&
        ['None', 'NA', 'FullAppraisal', 'DriveBy'].include?(loan.PropertyValMethod)
    end

    def fieldwork_and_pvm_missing?
      ['NA', nil].include?(loan.FieldworkObtained) && ['NA', nil, 'None'].include?(loan.PropertyValMethod)
    end

  end
end
