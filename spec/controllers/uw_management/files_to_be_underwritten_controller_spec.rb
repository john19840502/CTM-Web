require "spec_helper"

describe UwManagement::FilesToBeUnderwrittenController do
  render_views

  let(:instancey) { build_stubbed :files_to_be_underwritten, id: 12345 }

  before do
    fake_rubycas_login
    # Mock stuff that doesn't matter to get extra speed
    ActiveRecord::Relation.any_instance.stub(:count) { 100 }
    ActiveRecord::Relation.any_instance.stub(:all) { [FilesToBeUnderwritten.first] }
  end

  describe 'get :index' do
    before do
      get :index
    end

    it { should render_template 'index' }
  end

end