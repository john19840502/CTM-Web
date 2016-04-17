require 'spec_helper'

describe SettlementAgentAudit do
  subject { SettlementAgentAudit }
  let(:audit_service) {Closing::SettlementAgent::ReportData}
  before do
    subject.delete_all
  end

  let(:loan) { Loan.new }
  let(:audit) { SettlementAgentAudit.new({loan_id: "12345", settlement_agent: "Settlement Agent Corp", agent_page1: "Yes", agent_page2: "Yes", agent_page3: "Yes", seller_credit_changed: "No", realtor_credit_changed: "No", lender_credit_changed: "No"}, without_protection: true) }
  
  
  it "should raise exception when the required fields are not entered" do
    audit = subject.new({loan_id: "12345", settlement_agent: "Settlement Agent Corp", agent_page1: "Yes", agent_page2: "Yes", agent_page3: "Yes", seller_credit_changed: "No", realtor_credit_changed: "No"}, without_protection: true)
    expect(audit.save).to be_falsy
  end

  it ".get_month_to_month_comparison should return the comparison of agents for different months" do
    FactoryGirl.create(:settlement_agent_monthly_calculation, :settlement_agent => "Closing_agent1", :month => Date.new(2015,1,1), :hud_review => 6, :loans_funded => 4, :other_error_count => 2)
    FactoryGirl.create(:settlement_agent_monthly_calculation, :settlement_agent => "Closing_agent2", :month => Date.new(2015,1,1), :hud_review => 4, :loans_funded => 8)
    FactoryGirl.create(:settlement_agent_monthly_calculation, :settlement_agent => "Closing_agent1", :month => Date.new(2015,2,1), :hud_review => 6, :loans_funded => 4)
    FactoryGirl.create(:settlement_agent_monthly_calculation, :settlement_agent => "Closing_agent2", :month => Date.new(2015,2,1), :hud_review => 8, :loans_funded => 2)

    result = audit_service.get_month_to_month_comparison 2015

    expect(result.first[:YTD_Total_Loans_Funded]).to eq(8)
    expect(result.first[:'YTD_Total_Defect_Percentage_%']).to eq(58.335)
    expect(result.first[:monthly_report].size).to eq(2)
    expect(result.last[:monthly_report].first[:January_Loans_Funded]).to eq(8)
  end

  describe "branch manager" do
    let(:branch_employee) {build_stubbed(:branch_employee)}
    let(:datamart_user_profile) { build_stubbed(:datamart_user_profile, title: "Branch_manager", effective_date: Date.today, datamart_user_id: branch_employee.id)}
    it "should return branch manager for given loan" do
      audit.stub_chain(:loan, :loan_general, :branch, id: 6)
      manager_profile = DatamartUserProfile.should_receive(:where).and_return([datamart_user_profile])
      datamart_user_profile.should_receive(:branch_employee).and_return(datamart_user_profile)
      datamart_user_profile.stub_chain(:branch_employee, :name).and_return "Foo Bar"

      expect(audit.branch_manager).to eq("Foo Bar")
    end
  end

  it ".get_monthly_audits should return latest audits for the funded loans between time period." do
    start_date = Date.new(2010,12,1)
    end_date = Date.new(2010,12,31)
    funded_loans = build_stubbed_list(:funded, 2, :funded_at => Date.today)
    funded_loans.first.is_funded.should eq(true)

    loans = Loan.funded.funded_between(start_date, end_date)

    if !loans.empty?
      audits1 = FactoryGirl.create_list(:settlement_agent_audit, 2, :loan_id => loans.first.loan_num)
      loans.first.stub(:settlement_agent_audits).and_return audits1

      audits2 = FactoryGirl.create_list(:settlement_agent_audit, 3, :loan_id => loans.last.loan_num)
      loans.last.stub(:settlement_agent_audits).and_return audits2

      result = audit_service.get_monthly_audits(start_date, end_date)
      expect(result.size).to eq(2)
      expect(result.first.loan_id).to eq(loans.first.loan_num)
      expect(result.last.loan_id).to eq(loans.last.loan_num)
    else
      result = audit_service.get_monthly_audits(start_date, end_date)
      expect(result).to be_empty
    end
  end
end
