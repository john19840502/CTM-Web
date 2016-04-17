require 'spec_helper'
describe UnderwritingDatum do
  context "sqlserver views" do
    it { UnderwritingDatum::CREATE_VIEW_SQL.should_not be_empty }
    it { UnderwritingDatum.should respond_to(:sqlserver_create_view) }
    it { UnderwritingDatum.sqlserver_create_view.should_not be_empty }
  end
end
