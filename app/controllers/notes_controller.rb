class NotesController < RestrictedAccessController
    


  active_scaffold :note # do |config|
  #     config.list.columns = [:noteable, :entry_method, :body, :created_at]
  #   end
end
