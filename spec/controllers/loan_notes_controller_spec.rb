require "spec_helper"

describe LoanNotesController do
  let(:instancey) { build_stubbed :loan_note }

  before do
    @user = fake_rubycas_login
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
    it { should render_template 'list' }
  end

  describe 'get :show' do
    render_views

    before do
      get :show, id: instancey.id
    end

    it { response.should be_successful }
  end

  context 'user comes from somewhere' do
    before do
      request.env["HTTP_REFERER"] = "http://google.com"
    end

    context 'current user is not a ctm_user' do
      before do
        @user.stub(:ctm_user) { nil }
      end

      describe 'get :edit' do
        before do
          get :edit, id: instancey.id
        end

        it { should_not render_template :edit }
      end

      describe 'put :update' do
        before do
          instancey.should_not_receive(:update_attributes)
          put :update, id: instancey.id, loan_note: { blah: "blah" }
        end

        it { should_not redirect_to 'http://google.com' }
      end

      describe 'get :new' do
        before do
          get :new
        end

        it { should_not render_template :new }
      end

      describe 'post :create' do
        before do
          post :create, loan_note: { loan_id: 1 }
        end

        it { should_not redirect_to 'http://google.com' }
      end
    end

    context 'current user is a ctm_user' do
      before do
        @user.stub(:ctm_user) { build_stubbed :ctm_user }
      end

      describe 'get :edit' do
        before do
          get :edit, id: instancey.id
        end

        it { should render_template :edit }
        it "should assign the current user as the author of the note" do
          expect(assigns(:loan_note).ctm_user).to be_a CtmUser 
        end
      end

      describe 'put :update' do
        context "when update succeeds" do
          before do
            instancey.should_receive(:update_attributes).and_return(true)
            put :update, id: instancey.id, loan_note: { text: 'blah' }
          end

          it { should redirect_to 'http://google.com' }
        end

        context "when update fails" do
          it "should fail" do
            instancey.stub update_attributes: false
            put :update, id: instancey.id, loan_note: { text: 'blah' }
            response.should render_template :edit
            flash[:error].should == "Failed to update note"
          end
        end
      end

      describe 'get :new' do
        before do
          get :new
        end

        it { should render_template :new }
        it "should assign the current user as the author of the note" do
          expect(assigns(:loan_note).ctm_user).to be_a CtmUser
        end
      end

      describe 'post :create' do
        before do
          LoanNote.should_receive(:create) { true }
          post :create, loan_note: { note_type: 'blah' }
        end

        it { should redirect_to 'http://google.com' }
      end
    end
  end
end
