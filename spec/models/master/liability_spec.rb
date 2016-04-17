require 'spec_helper' #you can get rid of this if you get rid of references to Master::Loan

describe Master::Liability do
  describe 'test scopes used in other places' do
    it '#owned_by_ctm' do
      Master::Liability.where(liability_id: [100237, 91138]).owned_by_ctm.size.should == 1
    end

    it '#first_lien' do
      # 5174, 5141
      Master::Liability.where(liability_id: [5174, 5141]).first_lien.size.should == 1
    end

  end

  describe '#heloc?' do
    let(:true_heloc) do
      liability = Master::Liability.new
      liability.stub(:real_reo_property) { Master::ReoProperty.new }
      liability.subject_loan_resubordination_indicator = true
      liability.liability_type = 'HELOC'
      liability.unpaid_balance_amount = 1000
      liability
    end

    it 'requires a real reo property' do
      expect(true_heloc.heloc?).to be true
      true_heloc.unstub(:real_reo_property)
      expect(true_heloc.heloc?).to be_falsey
    end

    it 'requires resubordination' do
      expect(true_heloc.heloc?).to be true
      true_heloc.subject_loan_resubordination_indicator = false
      expect(true_heloc.heloc?).to be false
    end

    it 'requires the liability type to be HELOC' do
      expect(true_heloc.heloc?).to be true
      true_heloc.liability_type = 'not HELOC'
      expect(true_heloc.heloc?).to be false
    end

    it 'requires an unpaid balance or a heloc_maximum_balance_amount' do
      expect(true_heloc.heloc?).to be true
      true_heloc.unpaid_balance_amount = 0
      true_heloc.heloc_maximum_balance_amount = 0
      expect(true_heloc.heloc?).to be false
      true_heloc.heloc_maximum_balance_amount = 100
      expect(true_heloc.heloc?).to be true
    end

    it 'should only count if it is not being paid off' do
      true_heloc.payoff_status_indicator = true
      expect(true_heloc.heloc?).to be false
    end
  end

  describe '#paying_off?' do
    its(:paying_off?) { should be_falsey }
  end
end
