require 'spec_helper'

describe CreditSuissePostClosingExportsController do

  before do
    fake_rubycas_login
    # Mock stuff that doesn't matter to get extra speed
  end

  describe 'get :index' do
    render_views

    before do
      get :index
    end
    it { should render_template 'index' }
  end

  describe 'get :show' do
    render_views

    before do
      post_closing_files = [CreditSuissePostClosingFile.new({ id: 2345}, without_protection: true)]
      CreditSuissePostClosingFile.stub(:by_loan_id) { post_closing_files }
      Datatable.any_instance.stub(:record_list) { post_closing_files }
      Datatable.any_instance.stub(:model) { CreditSuissePostClosingFile }
      get :show, id: 2345
    end
    it { should render_template 'show' }
  end

end
