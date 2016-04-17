module Servicing
  class OtherDisbursementInfoBuilder < DisbursementInfoBuilderBase

    def initialize(loan, line_num)
      @hud_line_num = line_num
      super(loan)
    end

    def disbursement_name
      'Other'
    end

    def hud_line_num
      @hud_line_num
    end

    def name
      @name ||= derived_name
    end

    def type
      return 'T' if name =~ /town|village/
      return 'T' if name =~ /school/
      return 'T' if name =~ /sewer|sanitation|rail/
      
      return 'H' if name =~ /wind/ && loan.is_condo?
      return 'H' if name =~ /wind/
      return 'H' if name =~ /earthquake/

      return 'H' if name =~ /flood/ && loan.is_condo?
      return 'H' if name =~ /flood/
      return 'H' if name =~ /rental/

      return 'H' if name =~ /fire/ && loan.is_condo?
      return 'H' if name =~ /fire/
      return 'T' if name =~ /tax|parcel/
      return 'Z' if name =~ /insurance/ && loan.is_condo?
      return 'H' if name =~ /insurance/
      return 'E'
    end

    def expiration_date
      date if type.in? ['H','Z']
    end

    def payee_code_prefix
      return '9999' if name =~ /wind/ || name =~ /flood/
      '0999'
    end

    def payee_code_suffix
      return '99993' if name =~ /wind/ || name =~ /flood/
      '09991'
    end

    def certificate_identifier
      case name
      when /flood/
        loan.flood_insurance_policy_number.present? ? loan.flood_insurance_policy_number : 999_999_993
      when/wind/
        999_999_993
      else
        999_999_991
      end
    end

    def qualifier
      return '2' if name =~ /town|village/
      return '4' if name =~ /school/
      return '3' if name =~ /sewer|sanitation|rail/
      
      return '8' if name =~ /wind/ && loan.is_condo?
      return '3' if name =~ /wind/
      return '4' if name =~ /earthquake/

      return '7' if name =~ /flood/ && loan.is_condo?
      return '2' if name =~ /flood/
      return '0' if name =~ /rental/

      return '6' if name =~ /fire/ && loan.is_condo?
      return '1' if name =~ /fire/
      return '0' if name =~ /tax|parcel/
      return '7' if name =~ /insurance/ && loan.is_condo?
      return '0' if name =~ /insurance/
      return '2'
    end

    def  hud_line_matches_name?
      return false unless hud_line.present?

      regex = /#{name}/i unless name.eql?('*')
      if name == 'village'
        regex = /village|town/i
      end

      if name.in?(['insurance', 'tax'])
        exclude_regex = /hazard_insurance|rental|fire|flood|wind|earthquake/ if name.eql?('insurance')
        exclude_regex = /county_property_tax|parcel|city_property_tax|village|town|annual_assessments|sewer|sanitation|rail|school/ if name.eql?('tax')
        hud_line.user_defined_fee_name =~ regex && 
          hud_line.user_defined_fee_name !~ exclude_regex

      elsif name.eql?('*')
        hud_line.user_defined_fee_name !~ /hazard_insurance|rental|insurance|fire|flood_insurance|flood|wind|earthquake|mortgage_insurance|county_property_tax|tax|parcel|city_property_tax|village|town|annual_assessments|sewer|sanitation|rail|school/

      else
        hud_line.user_defined_fee_name =~ regex
      end
    end


    def derived_name
      fee_name = hud_line.try(:user_defined_fee_name)

      is_insurance = ->(fn) do
        fn =~ /insurance/i  &&
          fn !~ /hazard_insurance|rental|fire|flood|wind|earthquake/ 
      end

      is_tax = ->(fn) do
        fn =~ /tax/i &&
          fn !~ /county_property_tax|parcel|city_property_tax|village|town|annual_assessments|sewer|sanitation|rail|school/ 
      end

      is_other = ->(fn) do
        fn !~ /hazard_insurance|rental|insurance|fire|flood_insurance|flood|wind|earthquake|mortgage_insurance|county_property_tax|tax|parcel|city_property_tax|village|town|annual_assessments|sewer|sanitation|rail|school/
      end

      case fee_name
      when /village/i then 'village'
      when /town/i then 'town'
      when /rental/i then 'rental'
      when /fire/i then 'fire'
      when /flood/i then 'flood'
      when /wind/i then 'wind'
      when /earthquake/i then 'earthquake'
      when /parcel/i then 'parcel'
      when /sewer/i then 'sewer'
      when /sanitation/i then 'sanitation'
      when /rail/i then 'rail'
      when /school/i then 'school'
      when is_insurance then 'insurance'
      when is_tax then 'tax'
      when is_other then '*'
      end
    end
  end
end
