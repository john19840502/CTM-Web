module ChecklistDisplayConditions

  # Some of our models use logic to determine if the item
  # should be displayed for a particular loan.  Checklists, for example.
  def display_for_loan?(loan)
    
    # This logic assumes that the flags are unique... This could (will?)
    # fail for 'VA', since that is also the code for Virginia...
    # TODO - make this not fail for Virginia - Hans
    conditions = section_conditions
  
    # Use our logic tables...
    # is_display_for_all_loans or
    
    !FILTER_UWCHECKLIST_DISPLAY or
    conditions.empty? or
    conditions.include?(loan.property.state.upcase) or
    conditions.include?(loan.program) or
    conditions.include?(loan.purpose)
  end

  def section_conditions
    [conditions_to_array(state_display_conditions),
     conditions_to_array(loan_program_display_conditions),
     conditions_to_array(loan_purpose_display_conditions)].compact.flatten.uniq
  end

  def conditions_to_array(condition)
    condition.split(',').map{|i| i.strip.upcase} rescue []
  end
end