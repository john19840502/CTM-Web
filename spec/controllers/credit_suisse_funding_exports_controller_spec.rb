require 'spec_helper'

describe CreditSuisseFundingExportsController do

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
      funding_files = [CreditSuisseFundingFile.new({ id: 2345}, without_protection: true)]
      CreditSuisseFundingFile.stub(:by_loan_id) { funding_files }
      Datatable.any_instance.stub(:record_list) { funding_files }
      Datatable.any_instance.stub(:model) { CreditSuisseFundingFile }
      get :show, id: 2345
    end
    it { should render_template 'show' }
  end

end
