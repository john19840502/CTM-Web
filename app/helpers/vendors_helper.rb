module VendorsHelper

  def vendor_retail_states_column record, column
    display_state_list record.retail_states
  end

  def vendor_wholesale_states_column record, column
    display_state_list record.retail_states
  end

  def display_state_list states
    states.map{|state_title| state_title.state_full_name}.join(", ")
  end

end