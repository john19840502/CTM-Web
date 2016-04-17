require 'spec_helper'

describe RedwoodLoan do

  it "should be able to do first" do
    expect{ RedwoodLoan.first }.not_to raise_error
  end
end
