
class AccountingReportsController < ApplicationController
  def download_url
    report = AccountingReport.find(params[:id])
    render json: { url: report.bundle.url, name: report.bundle.original_filename }
  end
end


