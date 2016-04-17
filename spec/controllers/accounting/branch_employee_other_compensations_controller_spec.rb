require "spec_helper"

describe Accounting::BranchEmployeeOtherCompensationsController do
  render_views

  before do
    fake_rubycas_login
  end

  # @branch_employee_other_compensation = BranchEmployeeOtherCompensation.new(datamart_user_id: params[:uid], institution_id: params[:bid])

  describe 'get :new' 
  # do

  #   let(:non_plan) { BranchEmployeeOtherCompensation.new }

  #   before do
  #     uid = '12345'
  #     bid = '12345'
  #     BranchEmployeeOtherCompensation.should_receive(:where).with(datamart_user_id: uid, institution_id: bid).and_return(non_plan)
  #     get :new, uid: uid, bid: bid
  #   end

  #   it { should render_template 'new' }

  # end
end