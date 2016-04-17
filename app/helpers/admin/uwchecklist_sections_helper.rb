module Admin::UwchecklistSectionsHelper
  def uwchecklist_items_column(record)
    "#{record.uwchecklist_items.size} items"
  end
end
