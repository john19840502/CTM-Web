class Admin::UwchecklistItemsController < RestrictedAccessController
  active_scaffold :uwchecklist_item do |config|
    config.list.label = 'Underwriter Checklist Items'
    config.list.columns = [:is_active, :position, :uwchecklist_section, :value] #, :bullet_type, :state_display_conditions, :loan_program_display_conditions]
    
    config.create.columns = [:value, :is_active] #, :state_display_conditions, :loan_program_display_conditions]
    config.update.columns = [:value, :is_active] #, :state_display_conditions, :loan_program_display_conditions]
    
    config.columns[:is_active     ].label      = 'Display?'
    config.columns[:is_active     ].inplace_edit = :true
    config.columns[:is_active     ].list_ui = :checkbox

    config.columns[:value         ].inplace_edit = :true

  
  end
end
