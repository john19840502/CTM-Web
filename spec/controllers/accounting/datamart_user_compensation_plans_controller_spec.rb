require "spec_helper"

describe Accounting::DatamartUserCompensationPlansController do
  let(:branch_id) { 786 }
  let(:employee_id) { 6963 }
  let(:bc) { BranchCompensation.create!({institution_id: branch_id, name: 'hi'}, without_protection: true) }

  before do
    fake_rubycas_login
  end

  render_views

  it "get :new with bid and no plans" do
    get :new, bid: branch_id, eid: employee_id
    flash[:error].should include('No other plans are currently available.')
    response.should redirect_to core_originator_path(employee_id)
  end

  it "get :new with bid that has plans" do
    bc
    get :new, bid: branch_id, eid: employee_id
    response.should render_template("new_plans")
  end

  it "get :new with pid" do
    get :new, pid: bc.id
    response.status.should == 200
  end

  it "post :create should not crash" do
    post :create, { datamart_user_compensation_plan: { datamart_user_id: employee_id, branch_compensation_id: bc.id} }
    response.status.should == 200
  end

  it "post :update" do
    bc.branch_compensation_details << BranchCompensationDetail.create!({branch_compensation_id: bc.id, effective_date: Date.today - 1.day, lo_min: 1, lo_max: 2}, without_protection: true)
    other = BranchCompensation.create!({institution_id: branch_id, name: 'old plan'}, without_protection: true)
    other.branch_compensation_details << BranchCompensationDetail.create!({branch_compensation_id: other.id, effective_date: Date.today - 1.day, lo_min: 1, lo_max: 2}, without_protection: true)

    plan = DatamartUserCompensationPlan.create!({datamart_user_id: employee_id, branch_compensation_id: other.id, effective_date: Date.today}, without_protection: true)

    post :update, { id: plan.id, datamart_user_compensation_plan: { datamart_user_id: employee_id, branch_compensation_id: bc.id} }

    expect(flash[:error]).to eq nil
    response.should redirect_to accounting_branch_compensation_path(bc.id)
  end



end
