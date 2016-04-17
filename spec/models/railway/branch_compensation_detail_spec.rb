require 'spec_helper'

describe BranchCompensationDetail do
  before(:each) do
    @branch = Institution.first
    @branch.branch_compensations << BranchCompensation.create({name: 'Plan A'}, without_protection: true)
  end

  it '#to_label' do
    comp_det = create_bcd
    comp_det.to_label.should eq('Compensation Plan Details')
  end

  it '#tiered_split_adjustment' do
    comp_det = create_bcd
    comp_det.tiered_split_high = 2
    comp_det.tiered_split_low = 1
    comp_det.tiered_split_adjustment.to_i.should eq(1)
  end

  describe '#commission_percentage' do
    before(:each) do
      @comp_det = create_bcd
    end

    it 'lo_traditional_split' do
      @comp_det.lo_traditional_split = 1
      @comp_det.commission_percentage.to_i.should eq(1)
    end

    it 'tiered_split_low' do
      @comp_det.tiered_split_low = 3
      @comp_det.commission_percentage.to_i.should eq(3)
    end

    it 'everything else' do
      @comp_det.commission_percentage.should eq(0)
    end
  end

  context "when creating or updating" do
    it "should require branch_compensation, effective_date, lo_min, and lo_max" do
      comp_det = create_bcd

      expect(comp_det.valid?).to be false
      expect(comp_det.errors.full_messages).to match_array [
        "Branch compensation can't be blank", 
        "Effective Date can't be blank", 
        "Loan Officer Max (per loan) can't be blank", 
        "Loan Officer Min (per loan) can't be blank"]
    end

    it "should allow effective_date to be in the past" do
      comp_det = create_bcd(branch_compensation: @branch.branch_compensations[0], effective_date: 1.day.ago, lo_min: 600, lo_max: 1600)

      expect(comp_det.valid?).to be true
    end

    it "should not allow effective_date to be more than a year ago" do
      today = Date.new(2014, 10, 2)
      Date.stub today: today
      comp_det = create_bcd(branch_compensation: @branch.branch_compensations[0], effective_date: today - 367.days, lo_min: 600, lo_max: 1600)

      expect(comp_det.valid?).to be false
      expect(comp_det.errors.full_messages).to match_array [
        "Effective Date must be on or after 2013-10-02 00:00:00", ]
    end

    it "should allow lo_traditional_split XOR tiered_split" do
      comp_det = create_bcd(branch_compensation: @branch.branch_compensations[0], 
        effective_date: Date.today,
        lo_traditional_split: 0.03,
        tiered_split_low: 0.04, 
        lo_min: 600, 
        lo_max: 1600)

      expect(comp_det.valid?).to be false
      expect(comp_det.errors.full_messages).to match_array [
        "Can not have Traditional Split and Tiered Split simultaneously", ]
    end
  end

  context "when updating" do
    it "should not allow branch_compensation updates" do
      comp_det = create_bcd(branch_compensation: @branch.branch_compensations[0], effective_date: Date.today, lo_min: 600, lo_max: 1600)

      comp_det.branch_compensation = BranchCompensation.create({institution_id: @branch.id, name: 'Plan B'}, without_protection: true)
      comp_det.save
      expect(comp_det.errors.full_messages).to match_array [
        "Branch compensation Compensation Plan can not be changed", ]

      comp_det.reload.branch_compensation.should eq(@branch.branch_compensations[0])
    end
  end


  def create_bcd(opts={})
    BranchCompensationDetail.create opts, without_protection: true
  end
end
