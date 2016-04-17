require 'spec_helper'
describe TransmittalDatum do
  context "sqlserver views" do
    it { TransmittalDatum::CREATE_VIEW_SQL.should_not be_empty }
    it { TransmittalDatum.should respond_to(:sqlserver_create_view) }
    it { TransmittalDatum.sqlserver_create_view.should_not be_empty }
  end
end
