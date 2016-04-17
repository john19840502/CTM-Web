builder.COLLATERALS do
  builder.COLLATERAL do
    builder.PROPERTIES do
      builder.PROPERTY do
        builder.ADDRESS do
          builder.AddressLineText loan['AddressLineText1']
          builder.CityName loan['CityName1']
          builder.PostalCode loan['PostalCode1']
          builder.StateCode loan['StateCode1']
        end
        builder.FLOOD_DETERMINATION do
          builder.FLOOD_DETERMINATION_DETAIL do
            builder.SpecialFloodHazardAreaIndicator loan.SpecialFloodHazardAreaIndicator
          end
        end
        builder.PROJECT do
          builder.PROJECT_DETAIL do
            builder.CondominiumProjectStatusType loan.CondominiumProjectStatusType
            builder.FNMCondominiumProjectManagerProjectIdentifier loan.cpm_id
            builder.ProjectAttachmentType loan.ProjectAttachmentType
            builder.ProjectClassificationIdentifier loan['ProjectClassificationIdentifier']
            builder.ProjectDesignType loan.ProjectDesignType
            builder.ProjectDwellingUnitCount loan.ProjectDwellingUnitCount
            builder.ProjectDwellingUnitsSoldCount loan.ProjectDwellingUnitsSoldCount
            builder.ProjectLegalStructureType loan.ProjectLegalStructureType
            builder.ProjectName loan['ProjectName']
            builder.PUDIndicator loan.PUDIndicator
          end
        end
        builder.PROPERTY_DETAIL do
          builder.AttachmentType loan.AttachmentType
          builder.ConstructionMethodType 'SiteBuilt' #loan.ConstructionMethodType
          builder.FinancedUnitCount loan.FinancedUnitCount
          builder.PropertyEstateType loan.PropertyEstateType
          builder.PropertyFloodInsuranceIndicator loan.PropertyFloodInsuranceIndicator
          builder.PropertyStructureBuiltYear loan.PropertyStructureBuiltYear
          builder.PropertyUsageType loan.PropertyUsageType
        end
        builder.PROPERTY_UNITS do
          (1..4).each do |n|
            if loan.BedroomCount(n)
              builder.PROPERTY_UNIT do
                builder.PROPERTY_UNIT_DETAIL do
                  builder.BedroomCount loan.BedroomCount(n)
                  builder.PropertyDwellingUnitEligibleRentAmount loan.PropertyDwellingUnitEligibleRentAmount(n)
                end
              end
            end
          end
        end
        builder.PROPERTY_VALUATIONS do
          builder.PROPERTY_VALUATION do
            builder.AVMS do
              builder.AVM do
                builder.AVMModelNameType loan['AVMModelNameType']
              end
            end
            builder.PROPERTY_VALUATION_DETAIL do
              builder.AppraisalIdentifier loan['AppraisalIdentifier']
              builder.PropertyValuationAmount loan['PropertyValuationAmount']
              builder.PropertyValuationEffectiveDate loan['PropertyValuationEffectiveDate']
              builder.PropertyValuationFormType  loan.PropertyValuationFormType
              builder.PropertyValuationMethodType loan.valuation.valuation_type
            end
          end
        end
      end
    end
  end
end
