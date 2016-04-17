require 'spec_helper'

describe CreditSuisseAppraisalExportsController do

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
      appraisal_files = [CreditSuisseAppraisalFile.new({id: 2345}, without_protection: true)]
      CreditSuisseAppraisalFile.stub(:by_loan_id) { appraisal_files }
      Datatable.any_instance.stub(:record_list) { appraisal_files }
      Datatable.any_instance.stub(:model) { CreditSuisseAppraisalFile }
      get :show, id: 2345
    end
    it { should render_template 'show' }
  end

end
