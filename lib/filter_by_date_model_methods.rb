module FilterByDateModelMethods
  def filter_by_date(start_date, end_date)
    where(filter_by_date_method => start_date..end_date).filter_by_date_includes.order(filter_by_date_method)
  end

  def filter_by_date_method
    raise 'You must define a filter_by_date_method'
  end

  def filter_by_date_includes
    all
  end
end
