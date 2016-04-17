require "spec_helper"

describe Closing::ClosingRequestReceivedsController do
  render_views

  let(:instancey) { build_stubbed :closing_request_received }

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

  describe 'get :filter_by_date' do
    before do
      get :filter_by_date
    end

    it { should render_template 'filter_by_date' }
  end

end
