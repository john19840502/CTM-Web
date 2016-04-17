module Accounting::RegionsHelper

  def area_manager_regions_column(record, column)
    if record.area_manager_regions.count > 0
      record.area_manager_regions.map{|n| n.area_manager.name }.join(', ') rescue ''
    else
      'None'
    end
  end

end
