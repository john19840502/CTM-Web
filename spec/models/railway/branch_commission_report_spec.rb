require 'spec_helper'
describe BranchCommissionReport do
  before do
    @branch_report = BranchCommissionReport.new
    lo = DatamartUser.last
    lo.stub(:plan_commission_details).and_return(build_stubbed(:branch_compensation_detail))
    @lo_loan_commission = lo.plan_commission_details(Date.today)
    #@lo_loan_commission.stub_chain(:loan_general, :originator).and_return(lo)
    @loan = build_stubbed(:loan, :loan_amount => 100000)
    @loan.stub_chain(:loan_general, :originator).and_return(lo)
  end

  it "something" do
    expect{ 
      BranchCommissionReport.create!({report_month: '7', report_year: '2011', 
            report_period: '1'}, without_protection: true )
    }.not_to raise_error
  end

  it 'should return default lo_min' 
  # do
  #   @branch_report.send(:calc_commission, @loan, @lo_loan_commission, nil).to_f.should eql(300.0)
  # end

  it 'should return amount based on percentage > lo_min and < lo_max' 
  # do
  #   @branch_report.send(:calc_commission, @loan, @lo_loan_commission, 0.02).to_f.should eql(2000.0)
  # end

  it 'should return the lo_max based on percentage' 
  # do
  #   @branch_report.send(:calc_commission, @loan, @lo_loan_commission, 0.30).to_f.should eql(10000.0)
  # end

  it 'should return 0 if they are a branch store manager / non storefront' 
  # do
  #   @loan.stub_chain(:loan_general, :originator, :profile_title).and_return('Branch Manager / NON Storefront')
  #   @branch_report.send(:calc_commission, @loan, @lo_loan_commission, 0.30).to_f.should eql(0.0)
  # end

  it 'should return default loan commission if no loan officer' 
  # do
  #   @lo_loan_commission = nil
  #   @branch_report.send(:calc_commission, @loan, @lo_loan_commission, 0).to_f.should eql(DEFAULT_GROSS_COMMISSION.to_f)
  # end

end
