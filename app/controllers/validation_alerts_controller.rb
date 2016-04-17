class ValidationAlertsController < ApplicationController

  def clear
    alert = create_new_alert "Cleared"
    render json: alert
  rescue => e
    handle_json_error_response e
  end

  def reinstate
    alert = create_new_alert "Reinstated"
    render json: alert
  rescue => e
    handle_json_error_response e
  end

  private

  def create_new_alert action
    stuff = { user_id: current_user.uuid, loan_id: params[:loan_id], 
              rule_id: params[:rule_id], alert_type: params[:alert_type], 
              action: action, reason: params[:reason], text: params[:text] }
    ValidationAlert.create!(stuff, without_protection: true)
  end
end
