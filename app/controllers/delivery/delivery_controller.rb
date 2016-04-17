require 'filter_by_date_controller_methods'

class Delivery::DeliveryController < ApplicationController

  include FilterByDateControllerMethods

  before_filter :prepend_view_paths

  def prepend_view_paths
    prepend_view_path "app/views/delivery"
  end

  def index
     initialize_delivery
  end

  def export
    @delivery = delivery_model.find(params[:record_id])
    @loans = @delivery.loans self
    @delivery.originator(current_user)

    headers['Content-Type'] = "#{delivery_export_mime_type}"
    headers['Content-Disposition'] = "attachment; filename=#{delivery_export_filename}"
    headers['Cache-Control'] = ''
  end

  def loan_balance_details
    delivery = delivery_model.find(params[:id])
    loans = delivery.loans self
    data.model = loan_model
    data.records = loans
    data.columns = loan_data_columns

    respond_to do |format|
      format.html
      format.xls { send_data data.to_xls }
    end
  end

  def bony_mellon_export
    name = 'BONYMellonExportFile'
    value = params[:record_id]
    delivery_model.execute_procedure '[ctm].[usp_execute_ssis_package]', :package => %Q('<package name="#{name}"><variable name="PoolID" value="#{value}"/></package>')
    flash[:notice] = "Your file has been successfully exported!"
    redirect_to action: 'filter_by_date', start_date: params[:start_date], end_date: params[:end_date]
  end

  private############

  def filter_by_date_filename
    delivery_summary_filename
  end

  def filter_by_date_model
    delivery_model
  end

  def filter_by_date_columns
    pool_data_columns
  end
end
