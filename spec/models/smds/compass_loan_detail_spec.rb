require 'spec_helper'

describe Smds::CompassLoanDetail do

  let(:compass) {Smds::CompassLoanDetail.new}

  describe 'class methods' do
    subject { Smds::CompassLoanDetail }
    its(:sqlserver_create_view) { should be_a String }
  end

  describe ".race_entries" do
    context "It should return the races for given index" do
      before do
        compass.Brw1Race1 = "White"
        compass.Brw1Race2 = "Asian"
        compass.Brw2Race1 = "White"
        compass.Brw2Race2 = "Asian"
        compass.Brw2Race3 = "AmericanIndianOrAlaskaNative"
        compass.Brw2Race4 = "Asian"
        compass.Brw2Race5 = "White"
        compass.Brw3Race1 = "White"
        compass.Brw3Race2 = "BlackOrAfricanAmerican"
        compass.Brw3Race3 = "AmericanIndianOrAlaskaNative"
        compass.Brw3Race4 = "Asian"
        compass.Brw3Race5 = nil
        compass.Brw4Race1 = "White"
        compass.Brw4Race2 = nil
        compass.Brw4Race3 = "AmericanIndianOrAlaskaNative"
        compass.Brw4Race4 = "Asian"
        compass.Brw4Race5 = ""
      end
      # index is always one number prior the Borrower index. Example For Borrower 1, index is 0
      it "should return White, Asian list when borrower index is 0" do
        expect(compass.race_entries(0)).to eq(["White", "Asian"])
      end

      it "should return White, Asian, Asian, Asian, White when borrower index is 1" do
        expect(compass.race_entries(1)).to eq(["White", "Asian", "AmericanIndianOrAlaskaNative", "Asian", "White"])
      end

      it "should return White, BlackOrAfricanAmerican, AmericanIndianOrAlaskaNative, Asian, White when index is 2" do
        expect(compass.race_entries(2)).to eq(["White", "BlackOrAfricanAmerican", "AmericanIndianOrAlaskaNative", "Asian"])
      end

      it "should return White, AmericanIndianOrAlaskaNative, Asian when index is 3" do
        expect(compass.race_entries(3)).to eq(["White", "AmericanIndianOrAlaskaNative", "Asian"])
      end
    end
  end

  describe ".gender_type" do
    context "It should return the Borrower Gender based on index" do
      [[0, "Male"],
        [1, "Female"],
        [2, "Male"],
        [3, nil]
      ].each do |index, expected| 
        it "should return #{expected} when index is #{index}" do
          compass["Brw#{index+1}Gender"] = expected
          expect(compass.gender_type(index)).to eq expected
        end
      end
    end
  end

  describe "AssumabilityIndicator" do
    [['Fixed', false],
    ['AdjustableRate', true]
    ].each do |type , indicator|
      it "should return #{indicator} when LnAmortType is #{type}" do
        subject.stub LnAmortType: type
        expect(subject.AssumabilityIndicator).to eq indicator
      end
    end

    it "should return true when Assumable is Y" do
      subject.stub LnAmortType: 'Something'
      subject.stub Assumable: 'Y'
      expect(subject.AssumabilityIndicator).to eq true
    end

    it "should return false when LnAmortType is not Fixed or AdjustableRate" do
      subject.stub LnAmortType: 'NotFixed'
      expect(subject.AssumabilityIndicator).to eq false

      subject.stub LnAmortType: nil
      expect(subject.AssumabilityIndicator).to eq false
    end

    it "should return false when Assumable is Y but LnAmortType is Fixed" do
      subject.stub Assumable: "Y"
      subject.stub LnAmortType: "Fixed"
      expect(subject.AssumabilityIndicator).to eq false
    end
  end

  it { should_not be_readonly }
end
