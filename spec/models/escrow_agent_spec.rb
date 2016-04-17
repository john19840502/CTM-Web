require 'spec_helper'

describe EscrowAgent do
  subject { EscrowAgent }
  before do
    subject.delete_all
  end
  let(:escrow_agent) {subject.new()}
  describe "Validation for zipcode" do
    it "should raise validation error for zipcode invalid" do
      escrow_agent.zip_code = 123
      expect(escrow_agent.save).to be_falsy
      expect(escrow_agent.errors.full_messages.first).to eq("Zip code is blank or invalid.")
    end

    it "should save when the zip code is valid" do
      escrow_agent.zip_code = "12345-1234"
      escrow_agent.state = "CA"
      expect(escrow_agent.save).to be_truthy
    end
  end

  describe "Validation for state" do
    it "should raise validation error for length of state " do
      escrow_agent.zip_code = 12345
      escrow_agent.state = "Michaigan"
      expect(escrow_agent.save).to be_falsy
      escrow_agent.errors.full_messages.should include("State should be 2 character length.")
    end

    it "should allow blank value for state" do
      escrow_agent.zip_code = 12345
      escrow_agent.name = "Foo Bob"
      expect(escrow_agent.save).to be_truthy
    end

    it "should save when the state is valid" do
      escrow_agent.zip_code = 12345
      escrow_agent.state = "MI"
      expect(escrow_agent.save).to be_truthy
    end
  end
end
