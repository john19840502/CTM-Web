require 'spec_helper'
describe LoanFeature do
  context "sqlserver views" do
    it { LoanFeature::CREATE_VIEW_SQL.should_not be_empty }
    it { LoanFeature.should respond_to(:sqlserver_create_view) }
    it { LoanFeature.sqlserver_create_view.should eq(LoanFeature::CREATE_VIEW_SQL) }
  end
end
