require 'spec_helper'

describe AppendValidationWarningHistory do

  let(:warnings) { [ { rule_id: 30, text: 'abc'} ] }

  let(:loan_id) { "123" }

  it "should format messages" do
    expect(ValidationAlert.count).to eq 0
    x = AppendValidationWarningHistory.call warnings, loan_id
    expect(x.first).to eq({rule_id: 30, text: 'abc', history: []})
  end

  it "should append all the alert jsons for this rule and loan, most recent first" do
    a = ValidationAlert.create!({user_id: 'fred', loan_id: loan_id, rule_id: 30, text: 'abc',
           reason: 'foo', action: 'cleared'}, without_protection: true)
    b = ValidationAlert.create!({user_id: 'bob',  loan_id: loan_id, rule_id: 30, text: 'abc',
           reason: 'sdfklj', action: 'reinstated'}, without_protection: true)
    c = ValidationAlert.create!({user_id: 'bob',  loan_id: loan_id, rule_id: 31, text: 'xyz',
           reason: 'sdfklj', action: 'reinstated'}, without_protection: true)
    d = ValidationAlert.create!({user_id: 'bob',  loan_id: 999, rule_id: 30, text: 'abc',
           reason: 'sdfklj', action: 'reinstated'}, without_protection: true)
    ValidationAlert.any_instance.stub(:user_name) { |x| "#{x.user_id} name" }

    stuff = AppendValidationWarningHistory.call warnings, loan_id
    history = stuff.first[:history]
    expect(history.size).to eq 2
    expect(history.first["id"]).to match b.id
    expect(history.last["id"]).to match a.id
  end

  it "should correctly find and translate dates in messages" do
    appnd = AppendValidationWarningHistory.new warnings, loan_id
    stuff = appnd.send :fix_dates_in_message, 'Loans with qualification dates prior to 6/1/2013 must be manually qualified 1343145600000'

    expect(stuff).to match 'Loans with qualification dates prior to 6/1/2013 must be manually qualified 7/24/2012'
  end

  it "should correctly find and translate dates in messages" do
    appnd = AppendValidationWarningHistory.new warnings, loan_id
    stuff = appnd.send :fix_dates_in_message, "The Rate Lock Expiration Date of 1348243200000 is 5 business days or less from today's date."

    expect(stuff).to match "The Rate Lock Expiration Date of 9/21/2012 is 5 business days or less from today's date."
  end

  it "should ignore dates earlier than 07/24/2012" do
    appnd = AppendValidationWarningHistory.new warnings, loan_id
    stuff = appnd.send :fix_dates_in_message, "The Rate Lock Expiration Date of 48243200000 is 5 business days or less from today's date."

    expect(stuff).to match "The Rate Lock Expiration Date of 48243200000 is 5 business days or less from today's date."
  end

  it "should ignore non-dates" do
    appnd = AppendValidationWarningHistory.new warnings, loan_id
    stuff = appnd.send :fix_dates_in_message, "The loan amount of 200000 is too high"

    expect(stuff).to match "The loan amount of 200000 is too high"
  end

  it "should ignore non-dates" do
    appnd = AppendValidationWarningHistory.new warnings, loan_id
    stuff = appnd.send :fix_dates_in_message, "On the lock it was 21.5 but on the LE it was 21.500000001"

    expect(stuff).to match "On the lock it was 21.5 but on the LE it was 21.500000001"
  end
end
