
module Closing
  class PricingDetails
    attr_accessor :loan

    def initialize(loan)
      self.loan = loan
    end


    def premium_pricing_percent 
      manual = loan.collect_facttype("Premium Pricing Percent").try(:value)
      return manual if manual
      net_price_premium.round(3) if net_price_premium && net_price_premium > 0
    end

    def premium_pricing_amount
      manual = loan.collect_facttype("Premium Pricing Amount").try(:value)
      return manual if manual
      format_money loan.fact("TotalPremiumPricingAmount")
    end

    def discount_percent
      manual = loan.collect_facttype("Discount Percent").try(:value)
      return manual if manual
      net_price_premium.round(3) if net_price_premium && net_price_premium < 0
    end

    def discount_amount
      manual = loan.collect_facttype("Discount Amount").try(:value)
      return manual if manual
      format_money loan.transaction_detail.try(:borrower_paid_discount_points_total_amount)
    end

    private

    def format_money number
      return nil unless number
      '%.2f' % number
    end

    def net_price_premium
      @net_price ||= begin
                       np = loan.lock_price.try(:net_price).try(:to_f)
                       np.present? ? np - 100.0 : nil
                     end
    end
  end
end
