require 'spec_helper'
describe GfeDetail do

  context "sqlserver views" do
    it { GfeDetail::CREATE_VIEW_SQL.should_not be_empty }
    it { GfeDetail.should respond_to(:sqlserver_create_view) }
    it { GfeDetail.sqlserver_create_view.should_not be_empty }
  end

  it "should be properly translate gfe_disclosure_method_type for drools engine" do
    gfe_detail = build_stubbed :gfe_detail
    gfe_detail.should_receive(:gfe_disclosure_method_type) { "Mail" }

    gfe_detail.drools_translated_disclosure_method_type.should == 'US Mail'
  end

end
