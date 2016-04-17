require 'spec_helper'

describe BranchCompensation do
  context "when creating" do
    it "should require branch and name" do
      comp = build_branch_compensation

      expect(comp.save).to be false
      expect(comp.errors.full_messages).to match_array [ "Branch can't be blank", "Plan Name can't be blank" ]
    end

    it "should require a valid branch" do
      br_id = Institution.last.id + 1
      comp = build_branch_compensation(name: 'Plan A', institution_id: br_id)

      expect(comp.save).to be false
      expect(comp.errors.full_messages).to match_array [ "Branch can't be blank" ]
    end
  end

  it '#plan_package' do
    comp = build_bcd(effective_date: Date.yesterday)
    subject.stub_chain(:branch_compensation_details, :where, :order, :last).and_return(comp)
    subject.plan_package(Date.today).should eq(comp)
  end

  it '#current_or_future_package' do
    comp = build_bcd(effective_date: Date.yesterday)
    subject.stub_chain(:branch_compensation_details, :order, :last).and_return(comp)
    subject.current_or_future_package.should eq(comp)
  end

  context "when updating" do
    it "should not allow branch updates" do
      branch = Institution.first
      comp = build_branch_compensation(name: 'Plan A', institution_id: branch.id)
      comp.save

      comp.reload.branch.should eq(branch)

      branch_2 = Institution.last
      comp.branch = branch_2
      comp.name = 'Plan AAA'
      expect(comp.save).to be false
      expect(comp.errors.full_messages).to include "Branch Branch Compensation can not be re-assigned to a new Branch"

      comp.reload.branch.should_not eq(branch_2)
    end
  end

  def build_branch_compensation(opts={})
    BranchCompensation.new opts, without_protection: true
  end

  def build_bcd(opts={})
    BranchCompensationDetail.new opts, without_protection: true
  end
 
end
