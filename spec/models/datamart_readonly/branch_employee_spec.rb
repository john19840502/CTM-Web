require 'spec_helper'
describe LoanOfficerAudit do
  #subject { build_stubbed :loan_fact_daily }
  let(:lfd) { build_stubbed :loan_fact_daily }

  describe '#create_or_update_loan_officer_audit' do
    context 'with no loan general' do
      before { lfd.stub(:loan_general) { nil } }

      it 'should not create a LoanOfficerAudit' do
        LoanOfficerAudit.should_not_receive :create
        LoanOfficerAudit.create_or_update_loan_officer_audit(lfd)
      end
    end

    context 'with a loan general' do
      let(:loan_fact_daily) { build_stubbed :loan_fact_daily }

      context 'which has no loan' do
        it 'should not create a LoanOfficerAudit' do
          loan_fact_daily.stub_chain(:loan_general, :loan).and_return(nil)
          LoanOfficerAudit.should_not_receive :create
          LoanOfficerAudit.create_or_update_loan_officer_audit(loan_fact_daily)
        end
      end

      it 'should create a LoanOfficerAudit' do
        loan_general = build_stubbed(:loan_general)
        account_info = build_stubbed(:account_info)
        
        loan_fact_daily = build_stubbed(:loan_fact_daily)
        loan_fact_daily.stub(:loan_general).and_return(loan_general)
        loan_fact_daily.stub_chain(:loan_general, :originator).and_return(account_info)

        LoanOfficerAudit.should_receive(:create).and_return(true)
        LoanOfficerAudit.create_or_update_loan_officer_audit(loan_fact_daily)
      end

    end
  end

end
