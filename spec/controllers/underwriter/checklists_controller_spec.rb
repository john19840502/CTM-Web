require "spec_helper"

describe Underwriter::ChecklistsController do

  let(:instancey) { build_stubbed :loan }

  before do
    fake_rubycas_login
  end

  describe 'get :index' do
    before do
      # Mock stuff that doesn't matter to get extra speed
      ActiveRecord::Relation.any_instance.stub(:count) { 100 }
      ActiveRecord::Relation.any_instance.stub(:all) { [instancey] }
      get :index
    end

    it { should render_template 'index' }
  end

  describe 'get :search' do
    context 'with an id' do
      context 'with no commit' do
        before do
          get :search, loan_id: 12345
        end

        it { should redirect_to underwriter_checklist_path('12345', format: :html) }
      end
    end
  end

  describe 'get :show' do
    context 'with an id that does not correspond to any loan number' do
      before do
        Loan.stub(:find_by_loan_num).with('12345') { nil }
        get :show, id: '12345'
      end

      it { should redirect_to underwriter_checklists_path }
    end

    context "with an id that corresponds to a loan number" do
      before do
        Loan.stub(:find_by_loan_num).with('12345') { instancey }
      end

      describe 'in html format' do
        before do
          get :show, id: '12345', format: :html
        end

        it { should render_template 'show' }
      end

      describe 'in pdf format' do
        before do
          get :show, id: '12345', format: :pdf
        end

        it { should render_template 'show' }
      end
    end
  end
end
