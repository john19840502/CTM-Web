require 'spec_helper'

describe UwCoordinator::CondSubmittedNotReceivedController do
  render_views

  let(:instancey) { build_stubbed :cond_submitted_not_received }

  before do
    fake_rubycas_login
    # Mock stuff that doesn't matter to get extra speed
    ActiveRecord::Relation.any_instance.stub(:count) { 100 }
    ActiveRecord::Relation.any_instance.stub(:all) { [instancey] }
  end

  describe 'get :index' do
    before do
      get :index
    end

    it { should render_template 'index' }
  end
end
