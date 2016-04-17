ready_to_delay = loan.collect_facttype('right_to_delay')
if !ready_to_delay.nil?
  json.delay_date ready_to_delay.value
  json.delayed_by ready_to_delay.user_name
end

json.broker_texas_only loan.is_texas_50A6
fact_type_texas_only = loan.collect_facttype('texas_only')
if !fact_type_texas_only.nil?
  json.texas_only  fact_type_texas_only.value
  json.created_by  fact_type_texas_only.created_by
end

cash_to_close = loan.collect_facttype('cash_to_close').try(:value)
json.cash_to_close cash_to_close.nil? ? nil : cash_to_close.to_f

