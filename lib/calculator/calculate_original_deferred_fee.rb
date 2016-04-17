
module Calculator
  class CalculateOriginalDeferredFee

    def self.for(loan)
      new(loan).calculated_fee
    end

    attr_accessor :loan

    def initialize loan
      self.loan = loan
    end

    def calculated_fee
      raise "this calculator is only for post-TRID loans" unless loan.trid_loan?
      return unless loan.funded_at
      return if loan.cancelled_or_withdrawn_at
      return unless loan.is_portfolio_loan?
      return unless fas91

      fee = 0.0

      [ "Discount Points", "Origination Fee", "Administration Fee" ].each do |fee_name|
        fee += system_fee fee_name
      end

      [ "Premium Pricing", "Lender Paid Broker Compensation", "Lender Credit"
      ].each do |name|
        fee -= system_fee name
      end

      fee -= loan_officer_compensation
      fee -= deferred_wholesale_commission
      fee -= deferred_retail_commission_amount
      fee -= salary_and_benefits_amount
      fee -= loan_level_costs_amount

      fee
    end

    private

    def deferred_wholesale_commission
      pct = fas91.try(:deferred_wholesale_commission_percent) || 0
      loan.original_balance * pct
    end

    def deferred_retail_commission_amount
      fas91.try(:deferred_retail_commission_amount) || 0
    end

    def salary_and_benefits_amount
      fas91.try(:salary_and_benefits_amount) || 0
    end

    def loan_level_costs_amount
      fas91.try(:loan_level_costs_amount) || 0
    end

    def loan_officer_compensation
      relevant_hud_lines.find do |line|
        line.system_fee_name == "Loan Officer Compensation" &&
          line.paid_by == "Lender"
      end.try(:total_amount) || 0
    end

    def fas91
      @fas91 ||= loan.port_loan_fas91_params
    end

    def system_fee(name)
      relevant_hud_lines.find { |line| line.system_fee_name == name}.try(:total_amount) || 0
    end

    def relevant_hud_lines
      loan.hud_lines.hud.select { |line| line.net_fee_indicator }
    end
  end
end
