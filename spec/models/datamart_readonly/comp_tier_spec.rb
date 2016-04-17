require 'spec_helper'

describe CompTierFromView do

  let(:loan) { Loan.first }

  it "should be able to get the first comp tier" do
    expect { loan.comp_tiers_from_view.first }.not_to raise_error
  end
end
