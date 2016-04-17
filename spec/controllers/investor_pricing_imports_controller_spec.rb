require "spec_helper"

describe InvestorPricingImportsController do
  let(:instancey) { InvestorPricingImport.new }

  before do
    fake_rubycas_login
    # Mock stuff that doesn't matter to get extra speed
    ActiveRecord::Relation.any_instance.stub(:count) { 100 }
    ActiveRecord::Relation.any_instance.stub(:all) { [instancey] }
    ActiveRecord::Relation.any_instance.stub(:find) { instancey }
  end

  describe 'get :index' do
    render_views

    before do
      get :index
    end
    it { should render_template 'index' }
  end

  describe 'get :new' do
    render_views

    before do
      get :new
    end

    it { should render_template 'new' }
  end

  describe 'post :create' do
    render_views

    before do
      InvestorPricingImport.stub(:parse_file) { true }
      post :create, investor_pricing_import: { file: 'test_file' }
    end

    it { should redirect_to investor_pricing_imports_path }
  end
end
