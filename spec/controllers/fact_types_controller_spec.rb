require 'spec_helper'

describe FactTypesController do
  render_views

  before do
    fake_rubycas_login
  end

  describe 'get :index' do
    before do
      get :index
    end

    it 'should be successful' do
      expect(response).to be_successful
    end
  end

  describe 'get :search' do
    before do
      loan = Loan.new
      loan.stub(:fact_types) { {'InitialRateLockDate' => Date.today}}
      Loan.stub(:find_by_id).with('12345').and_return(loan)
      Decisions::Facttype.stub_chain(:new, :execute) {{'FactType' => 'Value'}}
      get :search, loan_id: '12345'
    end

    it 'should be successful' do
      expect(response).to be_successful
    end
  end
end
