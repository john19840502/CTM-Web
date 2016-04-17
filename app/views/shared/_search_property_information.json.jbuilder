#property
json.property_street loan.property_street
json.property_city   loan.property_city
json.property_state  loan.property_state
json.property_zip    loan.property_zip
json.property_county loan.property_county
json.property_address "#{loan.property_street} #{loan.property_city} #{loan.property_state} #{loan.property_zip} #{loan.property_county}"

json.gse_property_type loan.gse_property_type
json.property_num_of_units loan.property.num_of_units
json.purchase_price_amount loan.loan_general.transaction_detail.purchase_price_amount rescue nil
json.appraised_value loan.appraised_value
json.project_name loan.collect_facttype("Condo Project Name").try(:value) || loan.loan_general.try(:detail).try(:project_name)
json.project_code loan.loan_general.loan_feature.gse_project_classification_type rescue nil

project_classification = loan.try(:loan_feature).try(:fnm_project_classification_type)
if !project_classification.blank?
  if project_classification == "Other"
    project_classification = loan.loan_feature.fnm_project_classification_type_other_description
  end  
  json.project_classification project_classification
elsif project_classification.blank? && loan.loan_general.mortgage_term and %w(FHA VA).include?(loan.loan_general.mortgage_term.mortgage_type)
  json.project_classification 'N/A for this mortgage type'
else
  json.project_classification 'Not Found'
end

property_usage_type = loan.try(:loan_purpose).try(:property_usage_type)
if property_usage_type.blank?
  json.occupancy_type "Not Found"
elsif property_usage_type == "SecondHome"
  json.occupancy_type "Second Home"
elsif property_usage_type == "Investor"
  json.occupancy_type "Investment"
elsif property_usage_type == "PrimaryResidence"
  json.occupancy_type "Primary"
else
  json.occupancy_type "Unknown"
end

json.purpose_type loan.try(:loan_purpose).try(:loan_type).to_s.blank? ? "Unknown" : loan.loan_purpose.loan_type
