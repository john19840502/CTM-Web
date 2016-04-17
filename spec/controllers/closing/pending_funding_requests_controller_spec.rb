require "spec_helper"

describe Closing::PendingFundingRequestsController do
  render_views

  let(:instancey) { build_stubbed :pending_funding_request }

  before do
    fake_rubycas_login
    # Mock stuff that doesn't matter to get extra speed
    ActiveRecord::Relation.any_instance.stub(:count) { 100 }
    ActiveRecord::Relation.any_instance.stub(:all) { [instancey] }
    ActiveRecord::Relation.any_instance.stub(:find) { instancey }
  end

  describe 'get :index' do
    before do
      get :index
    end

    it { should render_template 'index' }
  end

end