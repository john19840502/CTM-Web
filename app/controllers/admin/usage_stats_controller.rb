class Admin::UsageStatsController < RestrictedAccessController

  def index
    redirect_to root_path unless current_user.roles.include? 'admin'
  end

  def controllers
    redirect_to root_path unless current_user.roles.include? 'admin'
  end

  def actions
    redirect_to root_path unless current_user.roles.include? 'admin'
    @actions = UsageStat.controller_actions(params[:ctrl])
  end

  def users
    redirect_to root_path unless current_user.roles.include? 'admin'
    @stats = UsageStat.user_stats(params).page(params[:page]).per(20)
  end

  def validate_loans
    redirect_to root_path unless current_user.roles.include? 'admin'
    Decisions::Validator.validate_loans
  end
end
