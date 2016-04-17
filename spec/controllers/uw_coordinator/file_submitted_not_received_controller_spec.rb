require 'spec_helper'

describe UwCoordinator::FileSubmittedNotReceivedController do

  let(:instancey) { build_stubbed :uw_submitted_not_received }

  before do
# Fakes our login but it dosn't catch our subdomain
    fake_rubycas_login
#    Mock stuff that doesn't matter to get extra speed
    ActiveRecord::Relation.any_instance.stub(:count) { 200 }
    ActiveRecord::Relation.any_instance.stub(:all) { [] }
    ActiveRecord::Relation.any_instance.stub(:find) { instancey }
  end

  describe 'get :index' do
    render_views
    before do
      get :index
    end
    it { should render_template 'index-erb'}
  end

  describe 'get :loan_counts' do
    render_views
    before do
      UwSubmittedNotReceived.stub(:date_counts) { {Date.new => 6} }
      get :loan_counts
    end

    it { should render_template 'loan_counts' }
  end

end
