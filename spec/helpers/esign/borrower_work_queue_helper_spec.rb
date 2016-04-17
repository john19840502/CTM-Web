require 'spec_helper'

describe Esign::BorrowerWorkQueueHelper do

  describe ".assignable_users" do

    it "should return the list of users that an assigner may see" do
      set_current_user "Mona", "Samaha"
      set_current_role "forced_registration_reassign"
      ret_val = helper.assignable_users
      expect(ret_val.size > 20).to be_truthy
      expect(ret_val.include? "Samaha, Mona").to be_truthy
    end

    it "should return only the current user for non-assigners on the list" do
      set_current_user "Lisa", "LeClaire"
      set_current_role "forced_registration_self_assign"
      ret_val = helper.assignable_users
      expect(ret_val.size).to eq 1
      expect(ret_val.first).to eq "LeClaire, Lisa"
    end

    it "should not return any users for anyone who cannot reassign or be assigned" do
      set_current_user "Sean", "Frost"
      set_current_role ""
      ret_val = helper.assignable_users
      expect(ret_val).to be_empty
    end

  end

  describe ".can_edit?" do

    it "should be true for assigners" do
      set_current_user "Charla", "Karlek"
      set_current_role "forced_registration_reassign"
      expect(helper.can_edit?).to be_truthy
    end

    it "should be true for assignees" do
      set_current_user "Kimberly", "Brothers"
      set_current_role "forced_registration_self_assign"
      expect(helper.can_edit?).to be_truthy
    end

    it "should be false for any non-assigner, non-assignee" do
      set_current_user "Tom", "Horrom"
      set_current_role ""
      expect(helper.can_edit?).to be_falsey
    end

  end

  def set_current_role role
    allow(helper).to receive(:user_roles).and_return [role]
  end

  def set_current_user first_name, last_name
    assigner = OpenStruct.new
    assigner.first_name = first_name
    assigner.last_name = last_name
    allow(helper).to receive(:current_user).and_return assigner
  end

end