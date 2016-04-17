require 'spec_helper'

RSpec.describe StateTitleVendor, :type => :model do

  let (:vendor1) {Vendor.find(1)}
  let (:vendor2) {Vendor.find(2)}
  
  describe "validations" do

    it "should only allow one entry per state" do
      existing_record = StateTitleVendor.find(1)
      new_record = StateTitleVendor.new(:state => existing_record.state, :retail_vendor_id => vendor1.id, :wholesale_vendor_id => vendor2.id)

      expect(new_record.valid?).to be_falsey
    end

    it "should require value for state" do
      new_record = StateTitleVendor.new(:retail_vendor_id => vendor1.id, :wholesale_vendor_id => vendor2.id)

      expect(new_record.valid?).to be_falsey
    end

    it "should require value for retail vendor id" do
      new_record = StateTitleVendor.new(:state => "BS", :wholesale_vendor_id => vendor2.id)

      expect(new_record.valid?).to be_falsey
    end

    it "should require value for wholesale vendor id" do
      new_record = StateTitleVendor.new(:state => "BS", :retail_vendor_id => vendor1.id)

      expect(new_record.valid?).to be_falsey
    end

    it "should not allow state to be edited" do
      existing_record = StateTitleVendor.find 1
      orig_val = existing_record.state
      existing_record.update(state: "foobar")

      expect(existing_record.state).to eq orig_val
    end

  end

end
