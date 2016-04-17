require 'delegate'
root = defined?(Rails) ? Rails.root : './' #Different folders are counted as "root" depending on whether you run this with a full rails environment or not.
Dir.glob(root + 'lib/translation/*.rb').each(&method(:require))

#A wrapper for loans to allow easy exporting to Fi Serv
class FiServLoan < SimpleDelegator
  def loan_type_number
    Translation::LoanTypeNumber.new(mortgage_type: mortgage_type, mi_indicator: mi_indicator).translate
  end
  alias :loan_type :loan_type_number

  def alternative_mortgage_indicator
    Translation::AlternativeMortgageIndicator.new(loan_amortization_type).translate
  end

  def loan_serv_product_code
    Translation::LoanServProductCode.new(product_code).translate
  end

  def state_code
    Translation::StateCode.new(property_state).translate
  end

  def property_type
    Translation::PropertyType.new(gse_property_type).translate
  end

  def branch
    institution_identifier[0..4]
  end

  def purpose
    Translation::Purpose.new(purpose_type: purpose_type, property_usage_type: property_usage_type).translate
  end

  def application_purpose
    Translation::ApplicationPurpose.new(purpose_type: purpose_type, property_usage_type: property_usage_type).translate
  end

  def pmi_company_code
    Translation::PmiCompanyCode.new(mi_company_id: mi_company_id, mortgage_type: mortgage_type).translate
  end

  def primary_gender
    Translation::Gender.new(primary_gender_type).translate
  end

  def primary_ethnicity
    Translation::Ethnicity.new(primary_hmda_ethnicity_type).translate
  end

  def primary_race
    Translation::Race.new(primary_hmda_race_type).translate
  end

  def primary_marital_status
    Translation::MaritalStatus.new(primary_marital_status_type).translate
  end

  def secondary_gender
    Translation::Gender.new(secondary_gender_type).translate
  end

  def secondary_ethnicity
    Translation::Ethnicity.new(secondary_hmda_ethnicity_type).translate
  end

  def secondary_race
    Translation::Race.new(secondary_hmda_race_type).translate
  end

  def secondary_marital_status
    Translation::MaritalStatus.new(secondary_marital_status_type).translate
  end

  #def asset_type_code
    # GJF 2013-06-10 commented this out b/c asset_type is not mapped correctly
    # for this to work.  Turns out a loan has more than one asset, not just a single one.
    # Will have to redo this translation somehow.
    # Translation::AssetTypeCode.new(asset_type).translate
  #end

  def flood_program_code

    if !flood_certification_identifier.blank? && 
      (flood_determination_nfip_community_participation_status_type.blank? || flood_determination_nfip_community_participation_status_type.eql?('Unknown'))
      return 'R'
    end

    Translation::FloodProgramCode.new(flood_determination_nfip_community_participation_status_type).translate
  end
end
