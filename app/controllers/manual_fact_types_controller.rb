class ManualFactTypesController < ApplicationController
  before_filter :find_loan, except: [:save]

  def save
    loan_num = params[:id]
    mfts = params[:manual_fact_types]
    saved_mfts = mfts.map do |name, value|
      ManualFactType.save_fact_type loan_num, name, value
    end
    render json: saved_mfts
  rescue Exception => e
    handle_json_error_response e
  end
end
