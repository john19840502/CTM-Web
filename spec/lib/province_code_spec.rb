require 'spec_helper'

describe ProvinceCode do
  subject do
    Object.new.tap do |o|
      o.extend ProvinceCode
    end
  end

  describe ".province_for_code" do

    context "with mapped postal code" do 
      it "should return Alabama for AL" do
        expect(subject.province_for_code("AL")).to eq "Alabama"
      end

      it "should return Alaska for AK" do
        expect(subject.province_for_code("AK")).to eq "Alaska"
      end
      
      it "should return Arizona for AZ" do
        expect(subject.province_for_code("AZ")).to eq "Arizona"
      end
      
      it "should return Arkansas for AR" do
        expect(subject.province_for_code("AR")).to eq "Arkansas"
      end
      
      it "should return California for CA" do
        expect(subject.province_for_code("CA")).to eq "California"
      end
      
      it "should return Colorado for CO" do
        expect(subject.province_for_code("CO")).to eq "Colorado"
      end
      
      it "should return Connecticut for CT" do
        expect(subject.province_for_code("CT")).to eq "Connecticut"
      end
      
      it "should return Delaware for DE" do
        expect(subject.province_for_code("DE")).to eq "Delaware"
      end
      
      it "should return Dist. of Columbia for DC" do
        expect(subject.province_for_code("DC")).to eq "Dist. of Columbia"
      end
      
      it "should return Florida for FL" do
        expect(subject.province_for_code("FL")).to eq "Florida"
      end
      
      it "should return Georgia for GA" do
        expect(subject.province_for_code("GA")).to eq "Georgia"
      end
      
      it "should return Hawaii for HI" do
        expect(subject.province_for_code("HI")).to eq "Hawaii"
      end
      
      it "should return Idaho for ID" do
        expect(subject.province_for_code("ID")).to eq "Idaho"
      end
      
      it "should return Illinois for IL" do
        expect(subject.province_for_code("IL")).to eq "Illinois"
      end
      
      it "should return Indiana for IN" do
        expect(subject.province_for_code("IN")).to eq "Indiana"
      end
      
      it "should return Iowa for IA" do
        expect(subject.province_for_code("IA")).to eq "Iowa"
      end
      
      it "should return Kansas for KS" do
        expect(subject.province_for_code("KS")).to eq "Kansas"
      end
      
      it "should return Kentucky for KY" do
        expect(subject.province_for_code("KY")).to eq "Kentucky"
      end
      
      it "should return Louisiana for LA" do
        expect(subject.province_for_code("LA")).to eq "Louisiana"
      end
      
      it "should return Maine for ME" do
        expect(subject.province_for_code("ME")).to eq "Maine"
      end
      
      it "should return Maryland for MD" do
        expect(subject.province_for_code("MD")).to eq "Maryland"
      end
      
      it "should return Massachusetts for MA" do
        expect(subject.province_for_code("MA")).to eq "Massachusetts"
      end
      
      it "should return Michigan for MI" do
        expect(subject.province_for_code("MI")).to eq "Michigan"
      end
      
      it "should return Minnesota for MN" do
        expect(subject.province_for_code("MN")).to eq "Minnesota"
      end
      
      it "should return Mississippi for MS" do
        expect(subject.province_for_code("MS")).to eq "Mississippi"
      end
      
      it "should return Missouri for MO" do
        expect(subject.province_for_code("MO")).to eq "Missouri"
      end
      
      it "should return Montana for MT" do
        expect(subject.province_for_code("MT")).to eq "Montana"
      end
      
      it "should return Nebraska for NE" do
        expect(subject.province_for_code("NE")).to eq "Nebraska"
      end
      
      it "should return Nevada for NV" do
        expect(subject.province_for_code("NV")).to eq "Nevada"
      end
      
      it "should return New Hampshire for NH" do
        expect(subject.province_for_code("NH")).to eq "New Hampshire"
      end
      
      it "should return New Jersey for NJ" do
        expect(subject.province_for_code("NJ")).to eq "New Jersey"
      end
      
      it "should return New Mexico for NM" do
        expect(subject.province_for_code("NM")).to eq "New Mexico"
      end
      
      it "should return New York for NY" do
        expect(subject.province_for_code("NY")).to eq "New York"
      end
      
      it "should return North Carolina for NC" do
        expect(subject.province_for_code("NC")).to eq "North Carolina"
      end
      
      it "should return North Dakota for ND" do
        expect(subject.province_for_code("ND")).to eq "North Dakota"
      end
      
      it "should return Ohio for OH" do
        expect(subject.province_for_code("OH")).to eq "Ohio"
      end
      
      it "should return Oklahoma for OK" do
        expect(subject.province_for_code("OK")).to eq "Oklahoma"
      end
      
      it "should return Oregon for OR" do
        expect(subject.province_for_code("OR")).to eq "Oregon"
      end
      
      it "should return Pennsylvania for PA" do
        expect(subject.province_for_code("PA")).to eq "Pennsylvania"
      end
      
      it "should return Rhode Island for RI" do
        expect(subject.province_for_code("RI")).to eq "Rhode Island"
      end
      
      it "should return South Carolina for SC" do
        expect(subject.province_for_code("SC")).to eq "South Carolina"
      end
      
      it "should return South Dakota for SD" do
        expect(subject.province_for_code("SD")).to eq "South Dakota"
      end
      
      it "should return Tennessee for TN" do
        expect(subject.province_for_code("TN")).to eq "Tennessee"
      end
      
      it "should return Texas for TX" do
        expect(subject.province_for_code("TX")).to eq "Texas"
      end
      
      it "should return Utah for UT" do
        expect(subject.province_for_code("UT")).to eq "Utah"
      end
      
      it "should return Vermont for VT" do
        expect(subject.province_for_code("VT")).to eq "Vermont"
      end
      
      it "should return Virginia for VA" do
        expect(subject.province_for_code("VA")).to eq "Virginia"
      end
      
      it "should return Washington for WA" do
        expect(subject.province_for_code("WA")).to eq "Washington"
      end
      
      it "should return West Virginia for WV" do
        expect(subject.province_for_code("WV")).to eq "West Virginia"
      end
      
      it "should return Wisconsin for  WI" do
        expect(subject.province_for_code("WI")).to eq "Wisconsin"
      end
      
      it "should return Wyoming for WY" do
        expect(subject.province_for_code("WY")).to eq "Wyoming"
      end
    
    end

    context "with bad data" do

      it "should return input if value not mapped" do
        expect(subject.province_for_code("foo")).to eq "foo"
      end

    end

  end

end
