require 'spec_helper'

RSpec.describe ManualFactType, :type => :model do

  it "should be invalid without loan_num" do
    expect(make_mft(loan_num: nil)).not_to be_valid
  end

  it "should be invalid without name" do
    expect(make_mft(name: nil)).not_to be_valid
  end

  it "should be invalid without value" do
    expect(make_mft(value: nil)).not_to be_valid
  end

  it "should be valid with all the stuff" do
    expect(make_mft).to be_valid
  end

  it "should fail to create when name does ot match the list of valid names" do
    expect(make_mft(name: "Foo")).not_to be_valid
  end

  def make_mft opts={}
    defaults = {
      loan_num: 123,
      name: "Type of Veteran",
      value: "bar",
    }

    ManualFactType.new defaults.merge(opts), without_protection: true
  end
end
