require "spec_helper"

describe ValidationAlert do

  context "when creating" do
    it "should require loan id, user id, action, reason, and rule id" do
      ir = ValidationAlert.new

      expect(ir.valid?).to be false
      expect(ir.errors.full_messages).to match_array [ "Action can't be blank", 
        "Loan can't be blank", "Reason can't be blank", "Rule can't be blank", 
        "User can't be blank", "Text can't be blank"
      ] 
    end
  end

  describe "as_json" do
    it "should include user_name" do
      uuid = 'abc'
      user = double
      user.stub display_name: 'foo'
      allow(User).to receive(:find).with(uuid).and_return(user)
      va = ValidationAlert.new({user_id: uuid}, without_protection: true)
      expect(va.as_json).to include user_name: 'foo'
    end

    it "should report user not found when can't find user" do
      uuid = 'abc'
      allow(User).to receive(:find).with(uuid).and_raise(ActiveResource::ResourceNotFound.new(nil))
      va = ValidationAlert.new({user_id: uuid}, without_protection: true)
      expect(va.as_json).to include user_name: 'User not found'
    end
  end
end
