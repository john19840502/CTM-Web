json.settlement_agent_name audit.settlement_agent
json.escrow_agent_name audit.escrow_agent && audit.escrow_agent.name
json.loan_number audit.loan_id
json.loan_status audit.loan.loan_status
json.property_street_addr audit.loan.property_street
json.property_city audit.loan.property_city
json.property_state audit.loan.property_state

json.loan_officer audit.loan_officer
json.closer_name audit.audited_name(audit.audited_by)
json.post_closer_name audit.audited_by_suspense.nil? ? nil : audit.audited_name(audit.audited_by_suspense) 
json.funder_name audit.loan.try(:funding_checklist).try(:created_by_user_name)
json.channel  audit.channel_name
json.branch_name audit.loan.loan_general.branch && audit.loan.loan_general.branch.to_label || nil
json.branch_id audit.loan.loan_general.branch && audit.loan.loan_general.branch.institution_number

json.wholesale_lender_name audit.loan.account_info && audit.loan.account_info.institution_name || nil
json.wholesale_lender_number audit.loan.account_info && audit.loan.account_info.institution_identifier || nil
json.area_manager audit.loan.area_manager
json.branch_manager audit.branch_manager || nil

json.product audit.loan_product_name
json.purchase_type audit.loan.loan_purpose && audit.loan.loan_purpose.loan_type || nil

json.closing_date audit.loan.closed_at && audit.loan.closed_at.strftime(I18n.t('date.formats.default')) || nil
json.funded_date audit.loan.funded_at && audit.loan.funded_at.strftime(I18n.t('date.formats.default')) || nil