cd_only = cd_only || @cd_only
json.disclose_by do
  if cd_only.try(:disclose_by_cd_at).present?
    json.cd_only              true
    json.disclose_by_cd_at    cd_only.disclose_by_cd_at.strftime('%m/%d/%Y %I:%S %p')
    json.disclose_by_cd_user  User.find(cd_only.disclose_by_cd_user_uuid).try(:display_name)
  else
    json.cd_only false
  end
  if @loan.loan_general.try(:loan_detail).try(:cd_disclosure_date).present?
    json.cd_already_sent_at @loan.loan_general.loan_detail.cd_disclosure_date.strftime('%m/%d/%Y %I:%S %p') 
    json.cd_already_sent true
  else
    json.cd_already_sent false
  end
end
