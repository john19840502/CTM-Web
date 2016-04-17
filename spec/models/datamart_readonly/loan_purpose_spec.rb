require 'spec_helper'
describe LoanPurpose do
  context "sqlserver views" do
    it { LoanPurpose::CREATE_VIEW_SQL.should_not be_empty }
    it { LoanPurpose.should respond_to(:sqlserver_create_view) }
    it { LoanPurpose.sqlserver_create_view.should_not be_empty }
  end
end
