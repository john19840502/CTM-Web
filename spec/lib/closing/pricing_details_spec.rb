require 'spec_helper'

RSpec.describe Closing::PricingDetails do
  let(:loan) { Loan.new }
  let(:details) { Closing::PricingDetails.new loan }

  describe "premium_pricing_percent" do
    before do
      allow(loan).to receive(:collect_facttype).and_return(nil)
    end

    it "should be the manual entry value if that's present" do
      stub_manual_entry "Premium Pricing Percent", 123
      expect(details.premium_pricing_percent).to eq 123
    end

    it "should be the net price less 100 if net price > 100" do
      loan.stub_chain(:lock_price, :net_price).and_return(101.235)
      expect(details.premium_pricing_percent).to eq 1.235
    end

    it "should be nil if net price is <= 100" do
      loan.stub_chain(:lock_price, :net_price).and_return(99.999)
      expect(details.premium_pricing_percent).to eq nil
    end

    it "should be nil if net price is nil" do
      loan.stub_chain(:lock_price, :net_price).and_return(nil)
      expect(details.premium_pricing_percent).to eq nil
    end
  end

  describe "premium_pricing_amount" do
    before do
      loan.stub(:fact).with("TotalPremiumPricingAmount").and_return 123
    end

    it "should be the manual value if present" do
      stub_manual_entry "Premium Pricing Amount", 456
      expect(details.premium_pricing_amount).to eq 456
    end

    it "when not manually entered should be the same as the fact type with 2 decimals" do
      expect(details.premium_pricing_amount).to eq "123.00"
    end

    it "should not break for nil" do
      loan.stub(:fact).with("TotalPremiumPricingAmount").and_return nil
      expect(details.premium_pricing_amount).to eq nil
    end
  end

  describe "discount_percent" do
    it "should be the manual value if present" do
      stub_manual_entry "Discount Percent", 456
      expect(details.discount_percent).to eq 456
    end

    it "should be the net price less 100 if net price < 100" do
      loan.stub_chain(:lock_price, :net_price).and_return(99.235)
      expect(details.discount_percent).to eq -0.765
    end

    it "should be nil if net price is >= 100" do
      loan.stub_chain(:lock_price, :net_price).and_return(100.001)
      expect(details.discount_percent).to eq nil
    end

    it "should be nil if net price is nil" do
      loan.stub_chain(:lock_price, :net_price).and_return(nil)
      expect(details.discount_percent).to eq nil
    end
  end

  describe "discount_amount" do
    it "should be the manual value if present" do
      stub_manual_entry "Discount Amount", 444
      expect(details.discount_amount).to eq 444
    end

    it "should come from transaction detail otherwise" do
      loan.stub_chain(:transaction_detail, :borrower_paid_discount_points_total_amount).and_return(555)
      expect(details.discount_amount).to eq "555.00"
    end

    it "should not break for nil" do
      loan.stub_chain(:transaction_detail, :borrower_paid_discount_points_total_amount).and_return(nil)
      expect(details.discount_amount).to eq nil
    end
  end

  def stub_manual_entry(name, value)
    mft = double(value: value)
    allow(loan).to receive(:collect_facttype).with(name).and_return(mft)
  end
end
