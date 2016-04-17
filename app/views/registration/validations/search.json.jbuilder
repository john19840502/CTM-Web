json.loan do
  json.partial! 'shared/search_loan_details' , loan: @loan
  json.partial! 'shared/search_borrowers_information', loan: @loan

  json.manual_fact_types @manual_fact_types
  json.signature_dates_match @signature_dates_match

  # #product description
  json.product_description @loan.try(:lock_price).try(:product_description)
  json.mortgage_type @loan.loan_general.try(:mortgage_term).try(:mortgage_type)
  json.ltv @loan.ltv.round(3)
  json.occupancy_type @loan.occupancy
  json.loan_officer_name @loan.try(:account_info).try(:originator).try(:name)
  json.property_state @loan.property_state
  json.loan_amount @loan.loan_amount

  json.base_loan_amount_1003 @loan.loan_general.mortgage_term.base_loan_amount
  json.total_loan_amount_1003 @loan.loan_general.transaction_detail.net_loan_disbursement_amount
  json.interest_rate_1003 @loan.mortgage_term.try(:requested_interest_rate_percent)
end
