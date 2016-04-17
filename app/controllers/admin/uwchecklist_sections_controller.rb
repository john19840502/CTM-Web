class Admin::UwchecklistSectionsController < RestrictedAccessController
  active_scaffold :uwchecklist_section do |config|
    config.list.label = 'Underwriter Checklist Sections'
    config.list.columns = [:is_active, :name, :column, :length, :body, :position, :uwchecklist_items, :is_display_for_all_loans, :state_display_conditions, :loan_program_display_conditions, :loan_purpose_display_conditions]
    
    # config.columns[:length].css_class = 'right'
    
    config.create.columns = [:name, :body, :state_display_conditions, :loan_program_display_conditions, :loan_purpose_display_conditions]
    config.update.columns = [:name, :body, :state_display_conditions, :loan_program_display_conditions, :loan_purpose_display_conditions, :is_display_for_all_loans]
    
    config.columns[:is_active                      ].label      = 'Display?'
    config.columns[:is_active                      ].inplace_edit = :true
    config.columns[:is_active                      ].list_ui = :checkbox
    
    config.columns[:is_display_for_all_loans       ].label      = 'All Loans?'
    config.columns[:is_display_for_all_loans       ].inplace_edit = :true
    config.columns[:is_display_for_all_loans       ].list_ui = :checkbox
    
    config.columns[:name                           ].inplace_edit = :true
    config.columns[:column                         ].inplace_edit = :true
    config.columns[:body                           ].inplace_edit = :true
    config.columns[:state_display_conditions       ].inplace_edit = :true
    config.columns[:loan_program_display_conditions].inplace_edit = :true
    config.columns[:loan_purpose_display_conditions].inplace_edit = :true
    
  end
end
