require 'spec_helper'

describe CtmExecs do
 
  it "should have first name" do
    :first_name.should_not be_blank
    # print "first name is not blank"
  end
  it "should have last name" do
    :last_name.should_not be_blank
    # print "last name is not blank"
  end

end

