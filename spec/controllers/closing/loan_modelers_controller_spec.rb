require 'spec_helper'

describe Closing::LoanModelersController do
  render_views

  before do
    fake_rubycas_login
  end

  describe 'get :show' do
    describe 'should look for the right modeler' do
      let(:loan) { Loan.new }

      before do
        loan_id = '12345'
        Loan.should_receive(:find_by_loan_num).with(loan_id).and_return(loan)
        get :show, id: loan_id
      end

      it 'sets the loan to @loan' do
        expect(response.status).to eql(200)
      end
    end
  end
end
