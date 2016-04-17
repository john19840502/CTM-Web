class LtvCalculatorBase
    attr_reader :product_code, :purpose_type, :base_loan_amount, :subordinate_lien_amount,
                :property_appraised_value_amount, :purchase_price_amount, :liability_amount,
                :mi_and_funding_fee_total_amount, :subordinate_lien_heloc_amount, 
                :undrawn_heloc_amount


    attr_accessor :total, :subordinate_total

    def initialize(options = {})
      @product_code                    = options[:product_code]
      @purpose_type                    = options[:purpose_type]
      @base_loan_amount                = options[:base_loan_amount].to_f
      @subordinate_lien_amount         = options[:subordinate_lien_amount].to_f 
      @property_appraised_value_amount = options[:property_appraised_value_amount].to_f
      @purchase_price_amount           = options[:purchase_price_amount].to_f
      @liability_amount                = options[:liability_amount].to_f
      @mi_and_funding_fee_total_amount = options[:mi_and_funding_fee_total_amount].to_f
      @subordinate_lien_heloc_amount   = options[:subordinate_lien_heloc_amount].to_f
      @undrawn_heloc_amount            = options[:undrawn_heloc_amount].to_f
    end

    def call
      return 0 if missing_product_code?
      set_subordinate_total
      set_total
      (calculate * 100).round(3)
    end

    # we don't have access to railsy blank? / present?, and this is a little less wordy than product_code.empty? || product_code.nil?
    def missing_product_code?
      product_code.to_s == ''
    end

    def set_subordinate_total
      @subordinate_total = subordinate_lien_amount  
    end

    def set_total
      @total = base_loan_amount.to_f + subordinate_total.to_f + liability_amount.to_f
    end

    def usda30fxd?
      product_code == 'USDA30FXD'  
    end

    def purchase?
      purpose_type == 'Purchase'
    end

    def refinance?
      purpose_type == 'Refinance'
    end

    def kind_of_construction?
      ["ConstructionOnly","Other","ConstructionToPermanent"].include?(purpose_type)
    end

    def appraised_or_purchase_amount
      values = [property_appraised_value_amount, purchase_price_amount].minmax

      return values[0] if values[0] != 0
      return values[1] if values[0] == 0 && values[1] != 0
      return 0
    end

    def calculate
      raise "Please define calculate in child class #{self.class.name}"
    end

    def calculate_not_usda30fxd_and_purchase
      raise "Please define calculate_not_usda30fxd_and_purchase in child class #{self.class.name}"
    end

    def calculate_not_usda30fxd_and_refinance 
      raise "Please define calculate_not_usda30fxd_and_refinance in child class #{self.class.name}"
    end

    def calculate_usda30fxd_and_other_purpose
      raise "Please define calculate_usda30fxd_and_other_purpose in child class #{self.class.name}"
    end

    def calculate_not_usda30fxd_and_other_purpose
      raise "Please define calculate_not_usda30fxd_and_other_purpose in child class #{self.class.name}"
    end

    def calculate_usda30fxd_and_purchase
      raise "Please define calculate_usda30fxd_and_purchase in child class #{self.class.name}"
    end

    def calculate_usda30fxd_and_refinance
      raise "Please define calculate_usda30fxd_and_refinance in child class #{self.class.name}"
    end

    def calculate_usda30fxd
      raise "Please define calculate_usda30fxd in child class #{self.class.name}"
    end


end
