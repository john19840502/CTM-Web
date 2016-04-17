module Accounting::AreaManagerRegionsHelper

  def area_manager_form_column(record, options)
    select :record, :area_manager, DatamartUser.area_managers.collect {|am| [ "#{am.last_name}, #{am.first_name}", am.id ] }
  end

  def area_manager_column(record, column)
    record.area_manager.name
  end

end
