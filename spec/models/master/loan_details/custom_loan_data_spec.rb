require 'spec_helper'

describe Master::LoanDetails::CustomLoanData do

  describe ".valid_consent_actions" do

    it "should return the valid actions" do
      expect(subject.valid_consent_actions).to eq ["No consent received", "Consent imaged"]
    end

  end

  describe ".consent_action" do

    before do
      subject.consent_complete = true
    end

    it "is valid with 'No consent received'" do
      subject.consent_action = "No consent received"
      expect(subject.valid?).to be_truthy
    end

    it "is valid with 'Consent imaged'" do
      subject.consent_action = "Consent imaged"
      expect(subject.valid?).to be_truthy
    end

    it "is valid with no value" do
      subject.consent_complete = false
      subject.consent_action = nil
      expect(subject.valid?).to be_truthy
    end

    it "is not valid with any other value" do
      subject.consent_action = "foodie"
      expect(subject.valid?).to be_falsey
    end

  end

  describe ".consent_complete" do

    it "is present if consent_action is set" do
      subject.consent_action = "Consent imaged"
      subject.consent_complete = true

      expect(subject.valid?).to be_truthy

      subject.consent_complete = false

      expect(subject.valid?).to be_falsey
    end

    it "is not present if consent_action is absent" do
      subject.consent_action = nil
      subject.consent_complete = false

      expect(subject.valid?).to be_truthy

      subject.consent_complete = true

      expect(subject.valid?).to be_falsey
    end

  end

end