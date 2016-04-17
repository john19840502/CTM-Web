#loan information
if ['REFIPLUS', 'REFINANCE'].include?(@loan.purpose)
  if !@loan.loan_purpose_description.blank?
    json.loan_purpose_type "#{@loan.loan_purpose} - #{@loan.loan_purpose_description}"
  end
else
  json.loan_purpose_type @loan.loan_purpose.to_s
end

json.total_balance_secondary_financing @loan.loan_general.total_balance_secondary_financing
json.max_amount_secondary_financing    @loan.loan_general.max_amount_secondary_financing
json.loan_amount @loan.loan_amount
json.occupancy @loan.occupancy
json.note_rate @loan.loan_general.lock_price.final_note_rate rescue nil
json.escrow_from_lock @loan.loan_general.escrow_from_lock rescue nil
json.escrow_from_1003 @loan.loan_general.escrow_from_1003 rescue nil
json.ltv @loan.ltv.round(3)
json.cltv @loan.cltv.round(3) rescue nil
json.hcltv @loan.hcltv.round(3) rescue nil
json.housing_ratio @loan.loan_general.mortgage_payment_to_income_ratio_percent
json.total_debt_ratio @loan.debt_to_income_ratio

# ASSET INFORMATION
json.total_funds_required_to_close loan.transaction_detail.total_funds_required_to_close