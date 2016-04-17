require 'spec_helper'

describe AreaManagerRegion do
  smoke_test :to_label

  context "when creating" do
    it "should require region and area manager" do
      ir = AreaManagerRegion.create

      ir.valid?

      ir.errors[:region].size.should == 1
      ir.errors[:area_manager].size.should == 1
    end

    it "should not allow area manager to be assigned to more than one region" do
      region1 = Region.create({name: 'Retail'}, without_protection: true)
      region2 = Region.create({name: 'Wholesale'}, without_protection: true)
      areamanager1 = DatamartUser.last

      AreaManagerRegion.create({region: region1, area_manager: areamanager1}, without_protection: true)

      ir2 = AreaManagerRegion.new({region: region2, area_manager: areamanager1}, without_protection: true)
      ir2.save

      ir2.valid?
      ir2.errors[:area_manager].size.should == 1
    end

    it "should not allow area manager to be assigned to the same region more than once" do
      region1 = Region.create({name: 'Retail'}, without_protection: true)
      areamanager1 = DatamartUser.last
      
      ir = AreaManagerRegion.create({region: region1, area_manager: areamanager1}, without_protection: true)

      ir2 = AreaManagerRegion.create({region: region1, area_manager: areamanager1}, without_protection: true)

      ir2.valid?
      ir2.errors[:area_manager].size.should == 1
    end
  end

end
