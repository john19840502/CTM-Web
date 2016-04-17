class CreateMersProcessing < ActiveRecord::Migration
  def change
    create_table :mers_reconciliation_reports do |t|
      t.string      :name
      t.date        :start_date
      t.date        :end_date
      t.references  :mers_import
      t.references  :dmi_import
      t.string      :status, :default => 'created'  # For state machine
      t.string      :bundle_file_name
      t.string      :bundle_content_type
      t.integer     :bundle_file_size
      t.datetime    :bundle_updated_at
      t.string      :bundle_fingerprint
      t.integer     :record_count
      t.string      :uuid
      t.timestamps
    end
    
    add_index :mers_reconciliation_reports, :name
    add_index :mers_reconciliation_reports, :status
    add_index :mers_reconciliation_reports, :mers_import_id
    add_index :mers_reconciliation_reports, :dmi_import_id
    add_index :mers_reconciliation_reports, [:start_date, :end_date]
    add_index :mers_reconciliation_reports, :uuid
    add_index :mers_reconciliation_reports, :bundle_file_name
    add_index :mers_reconciliation_reports, :bundle_updated_at
    
    #####
    # MERS Files
    #####
    
    create_table :mers_imports do |t|
      t.string      :name
      t.string      :status, :default => 'created'  # For state machine
      t.string      :format # The type of file it is - there are two as of creating this migration
      t.string      :bundle_file_name
      t.string      :bundle_content_type
      t.integer     :bundle_file_size
      t.datetime    :bundle_updated_at
      t.string      :bundle_fingerprint
      t.datetime    :mers_extract_at
      t.string      :mers_extract_org
      t.string      :mers_extracted_by_org
      t.integer     :mers_record_count
      t.string      :uuid
      t.timestamps
    end
    
    add_index :mers_imports, :name
    add_index :mers_imports, :format
    add_index :mers_imports, :uuid
    add_index :mers_imports, :bundle_file_name
    add_index :mers_imports, :bundle_updated_at
    
    create_table :mers_loans do |t|
      t.references  :mers_import
      t.references  :loan
      t.references  :mers_registration
      t.string      :min_num
      t.text        :data
      t.string      :uuid
      t.timestamps
    end
    
    add_index :mers_loans, :uuid
    add_index :mers_loans, :mers_import_id
    add_index :mers_loans, :loan_id
    add_index :mers_loans, :mers_registration_id  
    add_index :mers_loans, :min_num  
    
    #####
    # DMI Files
    #####
    
    create_table :dmi_imports do |t|
      t.string      :name
      t.string      :status, :default => 'created'  # For state machine
      t.string      :bundle_file_name
      t.string      :bundle_content_type
      t.integer     :bundle_file_size
      t.datetime    :bundle_updated_at
      t.string      :bundle_fingerprint
      t.datetime    :dmi_extract_at
      t.string      :dmi_extract_org
      t.string      :dmi_extracted_by_org
      t.integer     :dmi_record_count
      t.string      :uuid
      t.timestamps
    end
    
    add_index :dmi_imports, :name
    add_index :dmi_imports, :uuid
    add_index :dmi_imports, :bundle_file_name
    add_index :dmi_imports, :bundle_updated_at
    
    create_table :dmi_loans do |t|
      t.references  :dmi_import
      t.references  :loan
      t.references  :mers_registration
      t.string      :min_num
      t.text        :data
      t.string      :uuid
      t.timestamps
    end
    
    add_index :dmi_loans, :uuid
    add_index :dmi_loans, :dmi_import_id
    add_index :dmi_loans, :loan_id
    add_index :dmi_loans, :mers_registration_id  
    add_index :dmi_loans, :min_num  
    
    #####
    # EXCEPTIONS
    #####
    create_table :mers_exceptions do |t|
      t.references  :exceptionable, :polymorphic => true
      t.references  :mers_reconciliation_report
      t.string      :value
      t.text        :body
      t.boolean     :is_resolved,         :default => false
      t.boolean     :is_action_required,  :default => true
      t.string      :uuid
      t.timestamps
    end
    
    add_index :mers_exceptions, :uuid
    add_index :mers_exceptions, :mers_reconciliation_report_id
    add_index :mers_exceptions, :value
    add_index :mers_exceptions, [:exceptionable_id, :exceptionable_type]
    add_index :mers_exceptions, :is_resolved
    add_index :mers_exceptions, :is_action_required
  end
end
