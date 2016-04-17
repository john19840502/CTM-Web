module StateTitleVendorsHelper

  def state_title_vendor_state_column record, column
    record.state_full_name
  end
end