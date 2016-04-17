require 'spec_helper'

describe Smds::UlddMethods do
  let(:fnmaloan) { Smds::FnmaLoan.new }
  let(:fhlbloan) { Smds::FhlbLoan.new }
  let(:fhlmcloan) { Smds::FhlmcLoan.new }

  describe "#HMDARateSpreadPercent" do
    [0.0, 1.3].each do |apr_sprd|
      it "should return '' when APRSprdPct is #{apr_sprd}" do
        fnmaloan.stub APRSprdPct: apr_sprd
        expect(fnmaloan.HMDARateSpreadPercent).to eq ''

        fhlbloan.stub APRSprdPct: apr_sprd
        expect(fhlbloan.HMDARateSpreadPercent).to eq ''

        fhlmcloan.stub APRSprdPct: apr_sprd
        expect(fhlmcloan.HMDARateSpreadPercent).to eq ''
      end
    end

    it "should return the value stored in APRSprdPct when it is greater than 1.5" do
      fnmaloan.stub APRSprdPct: BigDecimal.new('1.8')
      expect(fnmaloan.HMDARateSpreadPercent).to eq "1.80"

      fhlmcloan.stub APRSprdPct: BigDecimal.new('11.84567')
      expect(fhlmcloan.HMDARateSpreadPercent).to eq '11.85'
    end
  end
end