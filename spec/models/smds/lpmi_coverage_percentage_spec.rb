require 'spec_helper'

describe Smds::LpmiCoveragePercentage do

  let(:lpmi_percent) {Smds::LpmiCoveragePercentage}

  [[95,30, 25],
  [88, 25, 12],
  [83, 12, 6],
  ].each do |ltv, percent1, percent2|
    it "should return #{percent1} when term is > 240 " do
      term = 245
      expect(lpmi_percent.percent(ltv, term)).to eq percent1
    end

    it "should return #{percent2} when term < 240 for LTV #{ltv} " do
      term = 123
      expect(lpmi_percent.percent(ltv,term)).to eq percent2
    end
  end

  it "should return 35 when LTV > 95" do
    term = 124
    ltv = 98
    expect(lpmi_percent.percent(ltv, term)).to eq 35
  end

  it "should return 0 when LTV <= 80" do
    expect(lpmi_percent.percent(70, 12)).to eq 0
  end
end