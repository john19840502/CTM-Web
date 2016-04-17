require 'spec_helper'

describe CreditSuisseLockExportsController do

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
      lock_files = [CreditSuisseLockFile.new({ id: 2345}, without_protection: true)]
      CreditSuisseLockFile.stub(:by_loan_id) { lock_files }
      Datatable.any_instance.stub(:record_list) { lock_files }
      Datatable.any_instance.stub(:model) { CreditSuisseLockFile }
      get :show, id: 2345
    end
    it { should render_template 'show' }
  end

  describe 'get :show with event_type set' do
    before do
      lock_files = [CreditSuisseLockFile.new({ id: 2345}, without_protection: true)]
      CreditSuisseLockFile.stub(:by_loan_id) { lock_files }
      Datatable.any_instance.stub(:record_list) { lock_files }
      Datatable.any_instance.stub(:model) { CreditSuisseLockFile }
      get :show, id: 2345, credit_suisse_lock_file: { event_type: 'something' }
    end

    it "should have records with an event type" do
      subject.data.records.first.event_type.should == 'something'
    end

  end

end
