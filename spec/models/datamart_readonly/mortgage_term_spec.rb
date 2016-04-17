require 'spec_helper'
describe MortgageTerm do
  context "sqlserver views" do
    it { MortgageTerm::CREATE_VIEW_SQL.should_not be_empty }
    it { MortgageTerm.should respond_to(:sqlserver_create_view) }
    it { MortgageTerm.sqlserver_create_view.should_not be_empty }
  end
end
