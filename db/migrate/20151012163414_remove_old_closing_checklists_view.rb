class RemoveOldClosingChecklistsView < ActiveRecord::Migration
  def up

    view_name = "ctmweb_closing_checklists_#{Rails.env}" 
    execute %Q{
      IF EXISTS(select * FROM sys.views 
                where name = '#{view_name}' 
                and schema_id = SCHEMA_ID('railway'))
        DROP VIEW [railway].[#{view_name}]
    }

    return unless Rails.env.development?
    execute %Q{
      IF EXISTS(select * FROM sys.views 
                where name = 'ctmweb_closing_checklists_jonathonjones' 
                and schema_id = SCHEMA_ID('railway'))
        DROP VIEW [railway].[ctmweb_closing_checklists_jonathonjones]
    }

    execute %Q{
      IF EXISTS(select * FROM sys.views 
                where name = 'ctmweb_closing_checklists_test' 
                and schema_id = SCHEMA_ID('railway'))
        DROP VIEW [railway].[ctmweb_closing_checklists_test]
    }
  end

  def down
    # view can be re-created by looking at the create statement in the model file deleted
    # in this commit
  end
end
