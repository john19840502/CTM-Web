module FilterByDateControllerMethods
  def filter_by_date
    data.label = filter_by_date_label if filter_by_date_label
    data.model = filter_by_date_model if filter_by_date_model
    data.records = filter_by_date_records if filter_by_date_records
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    data.records = data.model.filter_by_date(@start_date, @end_date) unless filter_by_date_records
    data.columns = filter_by_date_columns if filter_by_date_columns

    respond_to do |format|
      format.html
      format.xls { send_data data.to_xls, filename: filter_by_date_filename}
    end
  end

  private###############

  #NOTE: These should be overridden in the class that includes this module.

  def filter_by_date_label
  end

  def filter_by_date_model
  end

  def filter_by_date_columns
  end

  def filter_by_date_filename
    "#{filter_by_date_model.to_s.underscore}.xls"
  end

  def filter_by_date_records
  end
end
