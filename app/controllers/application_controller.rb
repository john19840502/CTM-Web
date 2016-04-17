class ApplicationController < ActionController::Base
  include AnalyticsClient
  include DatatablesControllerJunk
  protect_from_forgery

  # Have each controller enforce its own helpers
  # Global helpers should be put in application_helper.rb
  clear_helpers

  helper_method :data

  # Allow certain models and classes to access sessions - Hans (for CTMRoles)
  before_filter :expose_session_to_models

  # Defaults to the datatable pages if controller does not set its own
  before_filter :add_default_views

  # Set it up so that authentication and current user are the first filters run.  This is 
  # necessary because some gems (active_scaffold) set up before filters on 
  # ActionController::Base that require current_user to be set, and by default base class
  # before filters run earlier than derived class filters.  
  prepend_before_filter :initialize_current_ability
  prepend_before_filter :set_current_user
  prepend_before_filter CASClient::Frameworks::Rails::Filter if (Rails.env.production? || !ENV['ISOLATE'])

  before_filter :set_current_navigation

  # Record some statistics

  before_filter :record_usage_stats #if Rails.env.production?

  # ActiveScaffold.set_defaults do |config|
  #   config.security.default_permission = false
  # end

  # used for active scaffold errors
  def deny_access
    if request.xhr?
      if !flash[:ajax_error].blank?
        render text: flash[:ajax_error] 
      else
        render text: "You do not have sufficient permissions to perform this action."
      end
    else
      flash[:error] = "You do not have sufficient permissions to perform this action."
      redirect_to :back
    end
  rescue
    redirect_to root_path
  end

  # Do not use the default application layout for ajax requests - Hans
  layout proc{ |c| c.request.xhr? ? false : "application" }

  def add_default_views
    self.append_view_path("app/views/original-default")
  end

  def current_user
    @current_user
  end

  def audited_user
    current_user.user_summary
  end

  def logged_in?
    @current_user.present?
  end
  
  def delayed_job_admin_authentication
    # TODO - make this only visible to admins - Hans
    true
  end

  def user_roles
    session[:user_roles]
  end

  def user_groups
    session[:user_groups]
  end

  def user_menu_root
    session[:navigation_root]
  end

protected
  def permission_denied
    flash[:error] = "Sorry, you are not allowed to access that resource. [#{params[:controller]}:#{params[:action]} - #{request.url}] Roles: #{current_user.roles}"

    # Check if this is an ajax request      
    if request.xhr?
      render :partial => '/layouts/status_messages', :object => flash
      flash.discard
    else
      redirect_to :back || root_path
    end
  end

  # This breaks the rails MVC pattern, but the functionality needed trumps blind
  # adherance to the pattern, IMHO - Hans for CTMRoles
  def expose_session_to_models
    $_SESSION = session
  end

private

  def base_domain(host=request.host)
      # ctmweb.dev = 2
      # ctmweb = 1
      # We are going to get the last N elements of the request host, where n is equal to the domain size
      # domain_size determines how many elements of the domain are relevant to our current host.
      # ctmweb.dev = 2
      # ctmweb = 1
      domain_size = (ActionDispatch::Http::URL.tld_length + 1) * -1
      host.split('.')[domain_size..-1].join('.')
  end

  def set_current_user
    Rails.logger.debug "settign current user"
    @current_user = User.find(session[:cas_user])

    # We have to assign the session to the user so that we can access it during requests
    @current_user.session = session

    session[:user_roles] = @current_user.roles
    session[:user_groups] = @current_user.groups
    
    @current_user
  end

  def initialize_current_ability
    current_ability.merge(::Tss::Ability.new(current_user))
  end

  def set_current_navigation

    # Check to see if a context is passed as a param.  If so, let's check it and change things up
    if !!params[:navigation_context] && !!params[:navigation_name]
      # We are trying to change our context.
      # The navigation_context will be a uuid
      nav = Navigation.find_by_uuid(params[:navigation_context])

      # If nav is not found or the nav isn't a valid context, then redirect them to the landing page
      if Navigation.invalid_context?(params[:navigation_context], user_roles) or nav.nil?
        flash[:error] = "No navigation available for your roles: [#{user_roles.join(', ')}]"

        nav = Navigation.find_by_uuid(session[:navigation_context])   
        session[:navigation_context] = Navigation.default_context(user_roles)
        session[:navigation_root] = nav       

        flash[:notice] = "Changed your navigation to #{nav.label}"

        redirect_to portals_path
        return 
      else
        flash[:notice] = "Changed your navigation to #{nav.label}"
      end

      # We found a valid nav.  Set the session context.
      session[:navigation_context] = nav.uuid
      session[:navigation_root] = nav
    end

    # Check if their context is valid for their roles, and if not, set it to a valid context
    if session[:navigation_context].nil? #or Navigation.invalid_context?(params[:navigation_context], user_roles)
      session[:navigation_context] = Navigation.default_context(user_roles)
      session[:navigation_root] = Navigation.find_by_uuid(session[:navigation_context])
    end
  end

  def record_usage_stats
    UsageStat.record_usage_stats(request, params, session)
  end

  def handle_json_error_response exception
    logger.error ExceptionFormatter.new(exception)
    Airbrake.notify exception unless ENV["SKIP_AIRBRAKE_NOTIFY"] == "true"
    render status: 500, json: { message: exception.message, backtrace: exception.backtrace }
  end
end
