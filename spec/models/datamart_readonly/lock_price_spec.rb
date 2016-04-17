require 'spec_helper'
describe LockPrice do
  context "sqlserver views" do
    it { LockPrice::CREATE_VIEW_SQL.should_not be_empty }
    it { LockPrice.should respond_to(:sqlserver_create_view) }
    it { LockPrice.sqlserver_create_view.should_not be_empty }
  end
end
