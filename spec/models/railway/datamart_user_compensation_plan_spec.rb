require 'spec_helper'

describe DatamartUserCompensationPlan do

  before(:each) do
    @branch = Institution.all_retail.first
    @branch.branch_compensations << BranchCompensation.create({name: 'Plan A'}, without_protection: true)
    @branch.branch_compensations[0].branch_compensation_details << BranchCompensationDetail.create({branch_compensation: @branch.branch_compensations[0], effective_date: Date.today, lo_min: 600, lo_max: 1600}, without_protection: true)
  end

  it "should require compensation plan and user" do
    ducp = DatamartUserCompensationPlan.new

    expect(ducp.save).to be false
    expect(ducp.errors.full_messages).to match_array [
      "Branch compensation can't be blank", 
      "Datamart user can't be blank", 
      "Effective date can't be blank"]
  end

  it "should allow effective_date to be in the past" do
    employee = build_stubbed(:branch_employee)
    @branch.branch_compensations[0].branch_compensation_details[0].effective_date = 10.days.ago
    @branch.branch_compensations[0].branch_compensation_details[0].save!
    ducp = DatamartUserCompensationPlan.new({branch_compensation: @branch.branch_compensations[0], employee: employee, effective_date: 1.day.ago}, without_protection: true)
    
    expect(ducp.valid?).to be true
  end

  it "should not allow effective_date to be more than a year ago" do
    today = Date.new(2014, 10, 2)
    Date.stub today: today
    employee = build_stubbed(:branch_employee)
    ducp = DatamartUserCompensationPlan.create({branch_compensation: @branch.branch_compensations[0], employee: employee, effective_date: today - 367.days}, without_protection: true)

    expect(ducp.errors.full_messages).to include "Effective date must be on or after 2013-10-02 00:00:00"
  end

  it "should not allow effective_date to be earlier than effective_date of the plan" do
    @branch.branch_compensations[0].branch_compensation_details[0].effective_date = 10.days.since(Date.today)
    @branch.branch_compensations[0].branch_compensation_details[0].save!

    employee = build_stubbed(:branch_employee) 
    ducp = DatamartUserCompensationPlan.create({branch_compensation: @branch.branch_compensations[0], employee: employee, effective_date: Date.today.tomorrow}, without_protection: true)

    expect(ducp.errors.full_messages).to include "Effective date may not be before Plan's effective date"
  end

  it "should not allow a plan to be assigned if plan has no plan details" do
    @branch.branch_compensations[0].branch_compensation_details[0].destroy

    employee = build_stubbed(:branch_employee)
    ducp = DatamartUserCompensationPlan.create({branch_compensation: @branch.branch_compensations[0], employee: employee, effective_date: Date.today.tomorrow}, without_protection: true)

    expect(ducp.errors.full_messages).to include "Plan Name may not be selected because it has no details assigned"
  end

end
