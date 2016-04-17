FactoryGirl.define do
  factory :closing_requests_awaiting_review do
    loan_id (100000...600000).to_a.sample
    loan_purpose ["Refi", "Purc"].sample
    loan_status "U/W Approved w/Conditions"
    borrower "Simpson"
    state "MI"
    closing_at DateTime.now + 3.days
    submitted_at DateTime.now - 3.days
    lock_expire_at DateTime.now + 10.days
    channel 'A0'
  end
end
