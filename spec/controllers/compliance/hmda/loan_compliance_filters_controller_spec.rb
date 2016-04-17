require 'spec_helper'

describe Compliance::Hmda::LoanComplianceFiltersController do
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
