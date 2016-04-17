require "spec_helper"

describe Employment do
  smoke_test :name
  smoke_test :is_self_employed
  smoke_test :monthly_income

  context "sqlserver views" do
    it { Employment::CREATE_VIEW_SQL.should_not be_empty }
    it { Employment.should respond_to(:sqlserver_create_view) }
    it { Employment.sqlserver_create_view.should_not be_empty }
  end

  describe "scopes" do
    describe "current" do
      it "should require is_current to be true" do
        expect(Employment.current.new.is_current?).to be true
      end
    end
  end
end
