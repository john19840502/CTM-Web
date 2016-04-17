#borrowers
json.primary_borrower_mailing_address loan.primary_borrower_mailing_address
json.borrowers(loan.borrowers) do |borrower|
  json.first_name borrower.first_name
  json.last_name borrower.last_name
  json.ssn borrower.ssn
  json.credit_score borrower.credit_score
  json.is_citizen borrower.citizen?  
  json.is_permanent_alien borrower.permanent_alien?  
  json.intent_to_occupy borrower.permanent_alien?  
  json.current_employments(borrower.employments.current) do |employer|
    json.name employer.name
    json.is_self_employed employer.is_self_employed
  end
end
