require 'spec_helper'

describe LoanComplianceException do
  before do
    LoanComplianceEvent.delete_all
    event1.stub(:record_changes)
    event2.stub(:record_changes)
    ActiveRecord::Base.current_user_proc = nil
  end

  let!(:event1) { LoanComplianceEvent.create(aplnno: 1234, propstate: "NY") }  
  let!(:event2) { LoanComplianceEvent.create(aplnno: 1234, propstate: "MI") }
  let!(:range) { LoanComplianceEvent.all }
  let!(:range2) { LoanComplianceEvent.all }
  let!(:params) { {:aplnno => 1234, :propstate => 'MI'} } 
  let!(:user) { build_stubbed_user }
  subject { LoanComplianceException.new(range, range2, params, user) }

  describe "initialize" do
    describe 'instance variables' do
      its(:range) { should == range }
      its(:range2) { should == range2 }
      its(:params) { should == params }
      its(:user) { should == user }
    end
  end

  its(:uniq_aplnno) { should == ['1234'] }

  its(:import_cra_wiz) { should == [event1, event2] }

  # for this test, order is important
  its(:compare_periods) { should == 
    [[
      {:actdate=>[nil]},
      {:action_code=>[nil]},
      {:amort_term=>[nil]},
      {:amorttype=>[nil]},
      {:apdate=>[nil]},
      {:apeth=>[nil]},
      {:aplnno=>['1234']},
      {:appname=>[nil]},
      {:apptakenby=>[nil]},
      {:apr=>["0.000"]},
      {:aprace1=>[nil]},
      {:aprace2=>[nil]},
      {:aprace3=>[nil]},
      {:aprace4=>[nil]},
      {:aprace5=>[nil]},
      {:apsex=>[nil]},
      {:capeth=>[nil]},
      {:caprace1=>[nil]},
      {:caprace2=>[nil]},
      {:caprace3=>[nil]},
      {:caprace4=>[nil]},
      {:caprace5=>[nil]},
      {:capsex=>[nil]},
      {:censustrct=>[nil]},
      {:cntycode=>[nil]},
      {:denialr1=>[nil]},
      {:denialr2=>[nil]},
      {:denialr3=>[nil]},
      {:initadjmos=>[nil]},
      {:lnamount=>[nil]},
      {:lnpurpose=>[nil]},
      {:lntype=>[nil]},
      {:loan_prog=>[nil]},
      {:loan_term=>[nil]},
      {:macode=>[nil]},
      {:occupancy=>[nil]},
      {:preappr=>[nil]},
      {:propcity=>[nil]},
      {:propstate=>["NY", "MI"]},
      {:propstreet=>[nil]},
      {:proptype=>[nil]},
      {:propzip=>[nil]},
      {:purchtype=>[nil]},
      {:stcode=>[nil]},
      {:tincome=>[nil]}
    ]] 
  }

  describe "update_cra_wiz" do
    it "should update loan compliance event with reconciled value" do
      lambda { 
        LoanComplianceException.new(range, range2, params, user).update_cra_wiz
        event1.reload
        event2.reload
      }.should change(event1, :propstate).from("NY").to("MI")
    end
  end
end
