require 'spec_helper'
describe LoanFactDaily do

  context "sqlserver views" do
    it { LoanFactDaily::CREATE_VIEW_SQL.should_not be_empty }
    it { LoanFactDaily.should respond_to(:sqlserver_create_view) }
    it { LoanFactDaily.sqlserver_create_view.should_not be_empty }
  end
end
