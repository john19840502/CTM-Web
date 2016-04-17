require 'spec_helper'

describe Accounting::CommissionPlanDetailsController do
  render_views

  let(:instancey) { CommissionPlanDetail.first }

  before do
    u = fake_rubycas_login
    # Mock stuff that doesn't matter to get extra speed
    ActiveRecord::Relation.any_instance.stub(:count) { 100 }

    # Can't stub :all any more because it breaks datatables in rails 4.1.  Sadly that makes 
    # this test super slow. The Right Way to fix this is to split the query out into a query 
    # object, and stub that.  
    # ActiveRecord::Relation.any_instance.stub(:all) { [instancey] }
  end

  describe 'get :index' do
    before do
      get :index
    end

    it { should render_template 'index' }
  end
end
