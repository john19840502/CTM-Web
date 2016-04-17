require 'spec_helper'

describe Shipping do
  context "sqlserver views" do
    it { Shipping::CREATE_VIEW_SQL.should_not be_empty }
    it { Shipping.should respond_to(:sqlserver_create_view) }
    it { Shipping.sqlserver_create_view.should_not be_empty }
  end
end
