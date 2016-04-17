require 'spec_helper'

describe Compliance::Hmda::LoanComplianceEventsController do
  let(:current_user) { build_stubbed_user }
  before do
    fake_rubycas_login current_user
  end

  describe 'get :index' do
    let(:events) { LoanComplianceEvent.where('1=2')} 

    before do
      LoanComplianceEvent.stub for_period: events
    end

    it "should show the events for the range and report stored in the session" do
      session[:range] = 'foo'
      session[:report_type] = 'bar'
      LoanComplianceEvent.should_receive(:for_period).with('foo', 'bar').and_return(events)
      get :index
      assigns(:data).model.should == events
    end

    it "should include no more than 5 records when using json" do
      subject.data.should_receive(:as_json) do |options|
        options['iDisplayLength'].should == 5
      end
      get :index, format: :json
    end

    it "should do something sensible with xls format" do
      subject.data.stub to_xls: 'foo'
      subject.should_receive(:send_data).with('foo').and_call_original
      get :index, format: :xls
    end
  end

  describe 'get :import_form' do
    let(:events) { [] }
    before do
      session[:range] = 'session_range'
      session[:report_type] = 'session_report_type'
      LoanComplianceEvent.stub(:unexported_for_period).with('session_range', 'session_report_type').and_return(events)
    end

    it "should assign job_status when there is an upload id" do
      uploads = [ nil, double( job_status: 'foo' ) ]
      LoanComplianceEventUpload.stub(:where).with(id: '123').and_return(uploads)

      get :import_form, id: '123'
      assigns(:job_status).should == 'foo'
    end

    context "when there are unexported loans" do
      let(:events) do
        [ double(loan_compliance_event_upload: 'foo'), ]
      end
      before { get :import_form } 
      it "should assign the upload" do
        assigns(:loan_upload).should == 'foo'
      end
      it "should render the append form" do
        expect(response).to render_template(:append_form)
      end
    end

    context "when there are no unexported loans" do
      before { get :import_form } 
      it "should render the import form" do
        expect(response).to render_template(:import_form)
      end
    end
  end

  describe "set_session" do
    let(:base_params) { { m_period: '2', period_year: '2011', report_type: 'abc' } }
    let(:params) { base_params }

    before do
      LoanComplianceEvent.stub(:set_session_period).and_return('lsfjlkjsfkldj')
      LoanComplianceEvent.stub(:set_session_period).with('2', '2011', 'abc').and_return('foo')
      request.env["HTTP_REFERER"] = 'referer'
      get :set_session, params
    end

    it "should store the m_period if the q_period is missing" do
      session[:period].should == '2'
    end

    it "should store the report type" do
      session[:report_type].should == 'abc'
    end

    it "should store the period year" do
      session[:period_year].should == '2011'
    end

    it "should save the range from the calculation in LoanComplianceEvent" do
      session[:range].should == 'foo'
    end

    it "should redirect back" do
      response.should redirect_to('referer')
    end

    context "when q_period is present" do
      let(:params) { base_params.merge q_period: '3' }
      it "should store q_period in the session" do
        session[:period].should == '3'
      end
    end
  end

  describe "transform" do
    before do
      request.env["HTTP_REFERER"] = 'referer'
      LoanComplianceEvent.stub :do_transformations
    end

    context "when there are investors" do
      before do
        HmdaInvestorCode.stub investor_list: [ 'a' ]
      end
      it "should show an error" do
        get :transform
        flash[:error].should == 'Please update investor codes.'
        flash[:success].should == nil
      end
      it "should not attempt transformations" do
        LoanComplianceEvent.should_not_receive(:do_transformations)
        get :transform
      end
    end

    context "when there are no investors" do
      before do
        HmdaInvestorCode.stub investor_list: []
      end
      it "should show success message" do
        get :transform
        flash[:error].should == nil
        flash[:success].should == 'Transformations processed successfully.'
      end
      it "should do transformations" do
        LoanComplianceEvent.should_receive(:do_transformations)
        get :transform
      end
    end

    it "should redirect back" do
      get :transform
      response.should redirect_to("referer")
    end
  end

  describe "get import" do
    let(:upload) { LoanComplianceEventUpload.new }
    let(:file) { fixture_file_upload('spec/data/some_file.txt') }
    let(:params) { { lar_file: file, month: '5', year: '2011' }}

    before do
      LoanComplianceEventUpload.stub new: upload
      LoanComplianceEvent.stub :set_session_period
      upload.stub :save!
      upload.stub :add_periods
      upload.stub :process_upload
      LoanComplianceEvent.stub unexported: double(:update_all).as_null_object
    end

    it "should redirect to import_form" do
      upload.id = 123
      get :import, params
      response.should redirect_to(action: :import_form, id: 123)
    end

    it "should populate data in the upload and save it" do
      current_user.stub uuid: 'abcd'
      upload.should_receive(:add_periods).with('5', '2011')
      upload.should_receive :save!
      get :import, params
      upload.user_uuid.should == 'abcd'
      upload.hmda_loans.path.should include("some_file.txt")
    end

    it "should store some junk in the session" do
      LoanComplianceEvent.stub(:set_session_period).with('5', '2011', 'm').and_return('foo')
      get :import, params
      session[:report_type].should == 'm'
      session[:period].should == '5'
      session[:period_year].should == '2011'
      session[:range].should == 'foo'
    end

    it "should make a new job status" do
      expect { get :import, params }.to change{ JobStatus::JobStatus.count }.by(1)
      upload.job_status_id.should_not be_nil
    end

    it "should process the upload" do
      upload.should_receive :process_upload
      get :import, params
    end

    it "should set changed values to nil for all unexported events" do
      thing = double(:update_all)
      LoanComplianceEvent.stub unexported: thing
      thing.should_receive(:update_all).with(changed_values: nil)
      get :import, params
    end

    it "should report success" do
      get :import, params
      flash[:success].should == 'File has been successfully added to processing queue.'
    end

    context "when there is an error" do
      before { upload.stub(:save!).and_raise("Some error ~ no save for you!")}
      it "should flash the error split by tildes" do
        get :import, params
        flash[:error].should == [ "Some error ", " no save for you!"]
      end

      it "should redirect back to the form with no id" do
        get :import, params
        response.should redirect_to(action: :import_form)
      end
    end
  end

  describe "get :export" do
    let(:params) { { format: :csv, from: '5/11/2012', to: '6/16/2013' }}
    let(:events) { [] }

    before do
      LoanComplianceEvent.stub :reportable_events_between
      LoanComplianceEvent.stub(:reportable_events_between).with(Date.new(2012, 5, 11), Date.new(2013, 6, 16)).and_return(events)
      subject.stub :make_csv
    end

    it "should assign from and to" do
      get :export, params
      assigns[:from].should == Date.new(2012, 5, 11)
      assigns[:to].should == Date.new(2013, 6, 16)
    end

    it "should render some csv" do
      subject.stub(:make_csv).with(events).and_return('foo')
      get :export, params
      response.body.should == 'foo'
    end

    it "should set the exported_at time of the last upload containint hte events" do
      upload = LoanComplianceEventUpload.new
      events << LoanComplianceEvent.new
      events << LoanComplianceEvent.new(loan_compliance_event_upload: upload)
      upload.should_receive(:save)
      the_time = Time.new(2013, 12, 31, 23, 45)
      Time.stub now: the_time
      get :export, params
      upload.exported_at.should == the_time
    end
  end

  describe "get :edit" do
    it "should assign the event" do
      LoanComplianceEvent.stub_chain(:where, :where, :last).and_return('foo')
      get :edit, { id: '123'}
      assigns(:lce).should == 'foo'
    end
  end

  describe "post :update" do
    let(:event) { LoanComplianceEvent.create! aplnno: '123456789' }
    let(:params) { {id: event.id.to_s, loan_compliance_event: { amorttype: 'bar'} } }

    it "should assign the event" do
      post :update, params
      assigns(:lce).should == event
    end

    it "should render edit" do
      post :update, params
      response.should render_template(:edit)
    end

    it "should update the event with the parameters" do
      params[:loan_compliance_event] = { amorttype: 'foo' }
      post :update, params
      event.reload.amorttype.should == 'foo'
    end

    context "when update succeeds" do
      before do
        LoanComplianceEvent.any_instance.stub update_attributes: true
      end

      it "should save the user as last_updated_by" do
        current_user.stub display_name: 'fred'
        post :update, params
        event.reload.last_updated_by.should == 'fred'
      end

      context "when save succeeds" do
        before do
          event.stub save: true
          LoanComplianceEvent.stub find: event
        end
        it "should show success message" do
          post :update, params
          flash[:success].should include('success')
        end
      end
      context "when save fails" do
        before do
          event.stub save: false
          LoanComplianceEvent.stub find: event
        end
        it "should show errors" do
          event.errors.add(:aplnno, "is too boring")
          post :update, params
          flash[:error].should == event.errors.full_messages
        end
      end
    end

    context "when update fails" do
      before do
        event.stub update_attributes: false
        LoanComplianceEvent.stub find: event
      end

      it "should show an error" do
        event.errors.add(:aplnno, "is too boring")
        post :update, params
        flash[:error].should == event.errors.full_messages
      end

      it "should not change last_updated_by" do
        post :update, params
        event.reload.last_updated_by.should == nil
      end
    end
  end

  describe "post :mass_update" do
    let(:event) { LoanComplianceEvent.create! aplnno: '123456789' }
    let(:file) { fixture_file_upload('spec/data/some_file.txt') }
    let(:params) { { update_file: file, header: 'header' } }

    before do
      Compliance::Hmda::HmdaMassUpdate.any_instance.stub :mass_update
    end

    context 'when no file is specified' do
      let(:params) { { update_file: nil } }

      it "should show an error" do
        post :mass_update, params 
        flash[:error].should == "Please specify a file to upload."
      end
      it "should redirect to the update form" do
        post :mass_update, params 
        response.should redirect_to(action: :update_form)
      end
      it "should not attempt mass_update" do
        Compliance::Hmda::HmdaMassUpdate.any_instance.should_not_receive(:mass_update)
        post :mass_update, params 
      end
    end

    context "when the header is blank" do
      let(:params) { { update_file: 'foo', header: nil } }

      it "should show an error" do
        post :mass_update, params 
        flash[:error].should == "Please specify a header name."
      end
      it "should redirect to the update form" do
        post :mass_update, params 
        response.should redirect_to(action: :update_form)
      end
      it "should not attempt mass_update" do
        Compliance::Hmda::HmdaMassUpdate.any_instance.should_not_receive(:mass_update)
        post :mass_update, params 
      end
    end

    it "should mass update" do
      d = double(:mass_update)
      file.stub read: 'foo'
      Compliance::Hmda::HmdaMassUpdate.should_receive(:new).with('foo', 'header').and_return(d)
      d.should_receive :mass_update
      post :mass_update, params 
    end

    it "should redirect to index" do
      post :mass_update, params 
      response.should redirect_to(action: :index)
    end

    context "when mass update fails" do
      before do
        Compliance::Hmda::HmdaMassUpdate.any_instance.stub(:mass_update).and_raise('a~no')
        post :mass_update, params 
      end

      it "should show the error" do
        flash[:error].should == [ 'a', 'no' ]
      end

      it "should redirect to update form" do
        response.should redirect_to(action: :update_form)
      end

    end

  end
end
