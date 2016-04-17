require "spec_helper"

describe Closing::ClosingRequestsAwaitingReviewsController do
  render_views

  let(:instancey) { build_stubbed :closing_requests_awaiting_review }

  before do
    fake_rubycas_login
    # Mock stuff that doesn't matter to get extra speed
    ClosingRequestsAwaitingReview.any_instance.stub(:nmls_validity) { "awesome" }
    ClosingRequestsAwaitingReview.any_instance.stub(:nmls_errors) { {} }
    Datatable.any_instance.stub(:record_list) { [instancey] }
  end

  describe 'get :index' do
    before do
      get :index
    end

    it { should render_template 'index' }
  end

end