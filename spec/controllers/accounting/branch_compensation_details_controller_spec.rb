require "spec_helper"

describe Accounting::BranchCompensationDetailsController do

  render_views

  before do
    fake_rubycas_login
  end

  # describe 'get :show' do
  #   describe 'should look for the right originator' do
  #     let(:originator) { BranchEmployee.new }

  #     before do
  #       originator_id = '12345'
  #       BranchEmployee.should_receive(:where).with(id: originator_id).and_return(['vitaly', 'abdul', originator])
  #       get :show, id: originator_id
  #     end

  #     it 'sets the originator to @originator' do
  #       expect(assigns(:originator)).to eq(originator)
  #     end
  #   end
  # end

  # @plan = BranchCompensation.where(id: params[:pid]).last
  # @branch_compensation_detail = BranchCompensationDetail.new(branch_compensation_id: @plan.id)

  describe 'get :new' 
  # do

  #   let(:plan) { BranchCompensation.new }

  #   before do
  #     bc_id = '12345'
  #     BranchCompensation.should_receive(:where).with(id: bc_id).and_return([plan])
  #     get :new, pid: bc_id
  #   end

  #   it { should render_template 'new' }

  # end

end