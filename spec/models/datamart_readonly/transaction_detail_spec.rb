require 'spec_helper'
describe TransactionDetail do
  context "sqlserver views" do
    it { TransactionDetail::CREATE_VIEW_SQL.should_not be_empty }
    it { TransactionDetail.should respond_to(:sqlserver_create_view) }
    it { TransactionDetail.sqlserver_create_view.should_not be_empty }
  end
end
