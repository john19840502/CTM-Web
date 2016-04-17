class CreditSuisseOpsReportsController < ApplicationController
  load_and_authorize_resource

  active_scaffold :credit_suisse_ops_report do |config|
    config.label = 'Credit Suisse Ops Report'

    # config.actions.add :field_search
    # config.field_search.columns = :created_at

    config.list.columns = [:id, :name, :job_status, :created_at, :bundle]
    config.list.sorting = [{ :id => :desc }]
    config.update.columns = [:name, :start_date, :end_date, :status, :bundle]
    config.create.columns = [:start_date, :end_date]


    config.columns[:bundle].label = 'Report Links'
    config.actions.exclude :show
    config.actions.exclude :new
    config.actions.exclude :edit
    config.actions.exclude :delete
    config.actions.exclude :update

    config.columns[:job_status].label = 'Status'
    config.columns[:job_status].css_class = "as-job-status-container"
  end

  # def list_authorized?
  #   @current_user.is_secondary? || @current_user.is_pac? || @current_user.is_underwriter? || @current_user.is_lock_desk? || @current_user.is_post_closing?
  # end

  # def create_authorized?
  #   @current_user.is_secondary? || @current_user.is_pac? || @current_user.is_underwriter? || @current_user.is_lock_desk? || @current_user.is_post_closing?
  # end

  # def delete_authorized?
  #   @current_user.is_secondary? || @current_user.is_pac? || @current_user.is_underwriter? || @current_user.is_lock_desk? || @current_user.is_post_closing?
  # end

end
