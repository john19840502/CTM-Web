require 'spec_helper'

describe HmdaInvestorCode do
  subject { HmdaInvestorCode }
  before do
    subject.delete_all
    HmdaInvestorCode.create({investor_code: "0", investor_name: ["Cole Taylor"]}, without_protection: true)
  end

  describe "#update_code" do

    it "should create new investor code if there are no existing" do
      code = "6"
      investor = "CitiMortgage"
      subject.update_code(code, investor)
      subject.where(investor_code: "6").first.investor_name.should == ["CitiMortgage"]
    end

    it "should update existing investor code if one already exists" do
      code = "0"
      investor = "Secondary Hold"
      subject.update_code(code, investor)
      subject.where(investor_code: "0").first.investor_name.should == ["Cole Taylor", "Secondary Hold"]
    end
  end

  describe "#investor_codes" do
    it "should return hash of codes and investors" do
      subject.investor_hash.should == {"0" => ["Cole Taylor"]}
    end
  end
end
