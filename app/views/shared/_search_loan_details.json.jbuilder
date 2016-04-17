#loan details
json.loan_num loan.loan_num
json.channel  loan.channel
json.purpose_type loan.loan_purpose.loan_type rescue nil
json.trid_loan loan.trid_loan?
earnest_money_amount = loan.collect_facttype("Earnest Money Amount").try(:value) || loan.earnest_money_amount
json.earnest_money_amount '%.2f' % earnest_money_amount

payoff_amount = loan.loan_purpose.loan_type == 'Refinance' ? loan.transaction_detail.try(:refinance_including_debts_to_be_paid_off_amount) : ''
json.payoff_amount loan.collect_facttype("Payoff Amount").try(:value) || payoff_amount

json.product_code loan.product_code 
json.loan_status loan.loan_status 
json.lock_status loan.loan_general.try(:additional_loan_datum).try(:pipeline_lock_status_description)
json.loan_guideline_doc loan.loan_guideline_doc

json.precloser_name loan.loan_general.loan_assignees.closing_coordinator.first.try(:name).to_s
json.jr_underwriter_name loan.loan_general.loan_assignees.jr_underwriter.first.try(:name).to_s
json.underwriter_name loan.loan_general.loan_assignees.underwriter.first.try(:name).to_s
json.closer_name loan.loan_general.loan_assignees.closer.first.try(:name).to_s
json.second_closer_name loan.collect_facttype("Second Closer Name").try(:value)
json.processor_name loan.loan_general.loan_assignees.originator_processor.first.try(:name).to_s
json.processor_email loan.loan_general.requester.try(:email_address).to_s
json.title_company_name loan.title_company_name
json.title_company_email loan.loan_general.loan_detail.try(:document_email_address).to_s
json.lo_name loan.interviewer.try(:name).to_s
json.lo_email loan.account_info.try(:broker_email_address).to_s
json.broker_name loan.account_info.try(:broker_name).to_s
json.broker_office loan.is_wholesale? ? loan.account_info.try(:institution_name).to_s : ""
json.branch_name loan.is_wholesale? ? "" : loan.account_info.try(:institution_name).to_s
json.gse_property_type loan.gse_property_type
json.first_time_buyer loan.first_time_homebuyer? ? "Yes" : "No"
json.flood_zone loan.loan_general.flood_determination.try(:nfip_flood_zone_identifier)
json.va_fee_percent loan.loan_general.va_loan.try(:borrower_funding_fee_percent)
json.va_fee_amount loan.va_fund_fee_modeler

pricing_details = Closing::PricingDetails.new(loan)
json.premium_pricing_percent pricing_details.premium_pricing_percent
json.premium_pricing_amount  pricing_details.premium_pricing_amount
json.discount_percent        pricing_details.discount_percent
json.discount_amount         pricing_details.discount_amount
json.borrower_paid_percent   loan.collect_facttype("Borrower Paid Percent").try(:value)
json.borrower_paid_amount    loan.collect_facttype("Borrower Paid Amount").try(:value)

json.funds_requested_date begin
  if loan.loan_general.additional_loan_datum.present? && loan.loan_general.additional_loan_datum.pipeline_loan_status_description == 'Funding Request Received'
    loan.loan_general.additional_loan_datum.action_date_time_in_avista.strftime('%m/%d/%Y')
  else
    ""
  end
end

json.assigned_to_closer_date begin
  if loan.loan_general.loan_assignees.closing_coordinator.first.present?
    loan.loan_general.loan_assignees.closing_coordinator.first.assigned_at.strftime('%m/%d/%Y')
  elsif loan.loan_general.loan_assignees.closer.first.present?
    loan.loan_general.loan_assignees.closer.first.assigned_at.strftime('%m/%d/%Y')
  else
    ""
  end
end

json.closing_date begin
  if loan.loan_general.loan_detail.try(:closing_date)
    loan.loan_general.loan_detail.closing_date.strftime('%m/%d/%Y')
  else
    ""
  end
end

json.settlement_date begin
  if loan.loan_general.loan_detail.try(:disbursement_date)
    loan.loan_general.loan_detail.disbursement_date.strftime('%m/%d/%Y')
  else
    ""
  end
end

json.funding_date begin
  if loan.loan_feature.try(:requested_settlement_date)
    loan.loan_feature.requested_settlement_date.strftime('%m/%d/%Y')
  else
    ""
  end
end

json.requested_close_date begin
  if loan.loan_feature.try(:requested_closing_date)
    loan.loan_feature.requested_closing_date.strftime('%m/%d/%Y')
  else
    ""
  end
end

json.first_payment_date begin
  if loan.loan_general.try(:scheduled_first_payment_date)
    loan.loan_general.scheduled_first_payment_date.strftime('%m/%d/%Y')
  else
    ""
  end
end


#loan details
json.lock_details begin
  unless %w(Closed Funded).include?(loan.loan_status) or loan.try(:loan_general).try(:lock_price).nil?
    if lock_price = loan.loan_general.lock_price 
      json.lock_date lock_price.locked_at.strftime('%m/%d/%Y') if lock_price.locked_at
      json.lock_period lock_price.lock_period if lock_price.lock_period
      json.lock_expiration loan.lock_expiration_at.strftime("%m/%d/%Y") if lock_price.lock_expired_at
    end
  else
    json.not_locked true
  end
end

#program guidelines
json.program_guideline begin
	if guideline = loan.loan_guideline_doc
	  json.document guideline.document.to_s
	  json.document_file_name guideline.document_file_name
	  json.effective_date guideline.effective_date.strftime('%m/%d/%Y')
	end
end

#Closing Cash To / From Borrower
json.seller_credit_amount loan.purchase_credits.first.try(:credit_type).blank? ? "0.0" : loan.purchase_credits.try(:amount).to_f
