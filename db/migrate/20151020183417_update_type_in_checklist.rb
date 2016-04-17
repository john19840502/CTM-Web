class UpdateTypeInChecklist < ActiveRecord::Migration
  def change
    # Changing the value for already existing Closing Checklist entries
    Checklist.where(type: nil).update_all(type: 'ClosingChecklist')
  end
end
