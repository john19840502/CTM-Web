require "spec_helper"

describe Accounting::BranchCompensationsController do
  # extend AccessControlHelpers

  # should_be_list_authorized_for_only 'hr'
  # should_be_delete_authorized_for_only 'hr'
  # should_be_update_authorized_for_only 'hr'
  # should_be_create_authorized_for_only 'hr'

  before do
    fake_rubycas_login
  end

  describe 'get :index' do
    render_views

    before do
      get :index
    end
    it { should render_template 'index' }
  end

end
