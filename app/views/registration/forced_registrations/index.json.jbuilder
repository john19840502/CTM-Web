json.data @loans do |loan|
  if (loan.intent_to_proceed_date && loan.disclosure_date) && (loan.intent_to_proceed_date.beginning_of_day < loan.disclosure_date.beginning_of_day)
    json.loan_num_html build_loan_disclosure_warning(loan) 
  else
    json.loan_num_html loan.loan_num
  end

  json.loan_num loan.loan_num
  json.channel_type Channel.retail_all_ids.include?(loan.channel) ? 'Retail' : 'Wholesale'
  json.channel loan.channel
  json.product_name loan.product_name
  json.user_action loan.user_action
  json.comment loan.comment
  json.borrower loan.borrower
  json.state loan.state
  json.loan_officer loan.loan_officer
  json.lo_contact_email loan.lo_contact_email
  json.lo_contact_number loan.lo_contact_number
  json.area_manager loan.area_manager
  json.institution loan.institution
  json.branch loan.branch
  json.disclosure_date loan.disclosure_date.strftime('%m/%d/%Y')
  json.loan_status loan.loan_status
  json.intent_to_proceed_date loan.intent_to_proceed_date.strftime('%m/%d/%Y')
  json.intent_to_proceed_date_filter loan.intent_to_proceed_date.strftime('%Y%m%d')
  json.intent_age "#{loan.intent_age} days"
  json.intent_age_filter loan.intent_age
  json.assigned_to loan.assigned_to


  json.assignee build_reassign_form(loan)
  json.user_actions build_actions_select
  json.comments build_comments_table(loan)
  json.child_row build_child_row(loan)

end
