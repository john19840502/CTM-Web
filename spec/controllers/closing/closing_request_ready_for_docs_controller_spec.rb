require "spec_helper"

describe Closing::ClosingRequestReadyForDocsController do
  render_views

  let(:instancey) { build_stubbed :closing_request_ready_for_doc }

  before do
    fake_rubycas_login
    # Mock stuff that doesn't matter to get extra speed
    Datatable.any_instance.stub(:record_list) { [instancey] }
  end

  describe 'get :index' do
    before do
      get :index
    end

    it { should render_template 'index' }
  end

end
