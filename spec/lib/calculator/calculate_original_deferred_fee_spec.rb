require 'spec_helper'

RSpec.describe Calculator::CalculateOriginalDeferredFee do
  let(:loan) { Master::Loan.new }
  let(:fas91) { Smds::PortLoanFas91Parms.new }

  before do
    hud_lines = []
    hud_lines.stub :hud do
      hud_lines.select { |hl| hl.hud_type == "HUD" }
    end
    loan.stub hud_lines: hud_lines
    loan.stub port_loan_fas91_params: fas91
    loan.stub trid_loan?: true
    loan.stub is_portfolio_loan?: true
    loan.funded_at = Date.today - 1.day
    loan.original_balance = 0
  end

  it "should fail for pre-trid loans" do
    loan.stub trid_loan?: false
    expect{ Calculator::CalculateOriginalDeferredFee.for(loan) }.to raise_error /this calculator is only for post-TRID loans/
  end

  it "should be nil if the loan is not funded" do
    loan.funded_at = nil
    expect(Calculator::CalculateOriginalDeferredFee.for(loan)).to eq nil
  end

  it "should be nil if the loan was cancelled" do
    loan.cancelled_or_withdrawn_at = Date.today
    expect(Calculator::CalculateOriginalDeferredFee.for(loan)).to eq nil
  end

  it "should be nil if not a portfolio loan" do
    loan.stub is_portfolio_loan?: false
    expect(Calculator::CalculateOriginalDeferredFee.for(loan)).to eq nil
  end

  it "should be nil if there is no fas91 parameters" do
    loan.stub port_loan_fas91_params: nil
    expect(Calculator::CalculateOriginalDeferredFee.for(loan)).to eq nil
  end

  it "should add the discount points" do
    loan.hud_lines << hud_line(system_fee_name: "Discount Points", total_amount: 123.45)
    expect(Calculator::CalculateOriginalDeferredFee.for(loan)).to eq 123.45
  end

  it "should add the origination fee" do
    loan.hud_lines << hud_line(system_fee_name: "Origination Fee", total_amount: 123.46)
    expect(Calculator::CalculateOriginalDeferredFee.for(loan)).to eq 123.46
  end

  it "should add the admin fee" do
    loan.hud_lines << hud_line(system_fee_name: "Administration Fee", total_amount: 123.47)
    expect(Calculator::CalculateOriginalDeferredFee.for(loan)).to eq 123.47
  end

  it "should subtract the Premium Pricing" do
    loan.hud_lines << hud_line(system_fee_name: "Premium Pricing", total_amount: 123.47)
    expect(Calculator::CalculateOriginalDeferredFee.for(loan)).to eq -123.47
  end

  it "should subtract the Loan Officer Compensation if paid by lender" do
    loan.hud_lines << hud_line(system_fee_name: "Loan Officer Compensation", paid_by: "Lender", total_amount: 123.47)
    expect(Calculator::CalculateOriginalDeferredFee.for(loan)).to eq -123.47
  end

  it "should not subtract the Loan Officer Compensation if not paid by lender" do
    loan.hud_lines << hud_line(system_fee_name: "Loan Officer Compensation", paid_by: "Borrower", total_amount: 123.47)
    expect(Calculator::CalculateOriginalDeferredFee.for(loan)).to eq 0
  end

  it "should subtract the Lender Paid Broker Compensation" do
    loan.hud_lines << hud_line(system_fee_name: "Lender Paid Broker Compensation", total_amount: 123.47)
    expect(Calculator::CalculateOriginalDeferredFee.for(loan)).to eq -123.47
  end

  it "should subtract the Lender Credit" do
    loan.hud_lines << hud_line(system_fee_name: "Lender Credit", total_amount: 123.47)
    expect(Calculator::CalculateOriginalDeferredFee.for(loan)).to eq -123.47
  end

  it "should subtract the product of loan amount and fas91 deferred wholesale pct" do
    loan.original_balance = 100_000
    fas91.deferred_wholesale_commission_percent = 0.0009
    expect(Calculator::CalculateOriginalDeferredFee.for(loan)).to eq -90
  end

  it "should subtract the fas91 deferred retail commission" do
    fas91.deferred_retail_commission_amount = 2455
    expect(Calculator::CalculateOriginalDeferredFee.for(loan)).to eq -2455
  end

  it "should subtract the fas91 SalaryAndBenefitsAmt" do
    fas91.salary_and_benefits_amount = 895
    expect(Calculator::CalculateOriginalDeferredFee.for(loan)).to eq -895
  end

  it "should subtract the fas91 LoanLevelCostsAmt" do
    fas91.loan_level_costs_amount = 120
    expect(Calculator::CalculateOriginalDeferredFee.for(loan)).to eq -120
  end


  all_fee_names = [ "Discount Points", "Origination Fee", "Administration Fee", "Premium Pricing",
    "Loan Officer Compensation", "Lender Paid Broker Compensation", "Lender Credit",
  ]
  
  all_fee_names.each do |fee_name|
    it "should ignore #{fee_name} fees that are not hud_type HUD" do
      loan.hud_lines << hud_line(hud_type: "GFE", system_fee_name: fee_name, total_amount: 123.47)
      expect(Calculator::CalculateOriginalDeferredFee.for(loan)).to eq 0
    end
  end

  all_fee_names.each do |fee_name|
    it "should ignore #{fee_name} fees that are not net_fee_indicator = 1" do
      loan.hud_lines << hud_line(net_fee_indicator: 0, system_fee_name: fee_name, total_amount: 123.47)
      expect(Calculator::CalculateOriginalDeferredFee.for(loan)).to eq 0
    end
  end

  def hud_line(opts = {})
    defaults = {
      hud_type: "HUD",
      net_fee_indicator: 1
    }

    Master::HudLine.new defaults.merge(opts), without_protection: true
  end
end
