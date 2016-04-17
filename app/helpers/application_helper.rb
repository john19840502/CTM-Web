module ApplicationHelper
  def current_time
    DateTime.now.strftime('%m/%d/%Y %r')
  end

  def logged_in?
    @current_user.present?
  end
  
  def current_user
    @current_user
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

  def get_rails_env
    ":"+Rails.env unless Rails.env.production?
  end
  
  # Determine if a user has permission to access a controller/action combination
  def user_is_permitted?(resource=nil, action=nil)
    # route, match, params = Rails.application.routes.set.recognize(controller.request)
    # 
    # puts route.name
    # puts match
    # puts params
    # 
    action   = params[:action] rescue :index if action.nil?
    resourRce = params[:controller].split('/').split('/').last.singularize.camelize.constantize.new rescue nil if resource.nil?
    
    # puts "================================\n\n\n\n\n\n#{permitted_to? action, resource}\n#{action}\n#{resource}\n\n\n\n\n\n==========================="
    
    
    # return permitted_to? action, resource
    # TODO- make this actually return the stuff above
    true
  end


  # Take a current date time and format it so its pretty
  # Catches nil and empty strings, also parses string dates (Files to be Underwritten for example).
  def date_formatted(timestamp, options={})
    return "" if timestamp.blank?
    if timestamp.kind_of?(String)
      timestamp = Chronic.parse(timestamp)
    end
    # This should protect against Booleans or any other strange type.
    return "" unless ['Date', 'DateTime', 'Time'].include?(timestamp.class.name)
    I18n.localize(timestamp, options)
  end
 
  # keep here for an alias`
  def date_formatted_long(timestamp)
    date_formatted(timestamp, :format => :full_american)
  end

  def created_at_column(record, column)
    timestamp_display(record.created_at)
  end
  
  def updated_at_column(record, column)
    timestamp_display(record.updated_at) if record.updated_at
  end

  def job_status_column(record, column)
    render partial: 'shared/job_status/job_status', locals: { job_status: record.job_status, record_id: record.id }
  end
  
  def timestamp_display(datetime)
    time_ago_in_words(datetime) + ' ago'
  end
  
  def truth_as_yn(truth)
    truth.nil? ? nil : (truth ? 'Y' : 'N')
  end
  alias :truth_as_yes_no :truth_as_yn

  # Create a DOM id for a loan
  def dom_id_for_loan(loan)
    "loan_num_#{loan.loan_num}"
  end
  
  def hash_to_table(hash, header=true, reformat_labels=false )
    render :partial => '/layouts/shared/hash_to_table', :locals => {:hash => hash, :header => header, :reformat_labels => reformat_labels}
  end
  
  # Display a date in a specific format, or nil
  # if the date doesn't exist - Hans/Steve
  def date_or_nil(date, format = :default)
    I18n.l(date, :format => format) rescue nil
  end

  def full_purpose(purpose)
    case purpose
    when 'Refi'
      "Refinance"
    when 'Purc'
      "Purchase"
    else
      "Unknown"
    end
  end

 
  # def is_active_column(record)
  #   toggle_for(record, 'active')
  # end
  # 
  # # A generic boolean toggle using ajax to toggle is_[something] values for any class/controller
  # # This works as long as all conventions are followed.def followed.
  # # Note that the appropriate controller must have a 'toggle_confirmation' action.
  # 
  # def toggle_for(object, field)
  # 
  #   # %(<span class='toggle' id="record_#{object.id}_#{field}">) <<
  #   #    render(:partial => '/layouts/shared/toggle', :locals => {:field => field, :object => object}) <<
  #   # %(</span>)
  #   # render(:partial => '/layouts/shared/toggle', :locals => {:field => field, :object => object})
  #   return '<span class="toggle toggle_on">&nbsp;</span>'
  #   
  # end

  def loan_status_header_field(loan)
    html = ''
    html << "Loan Status: #{loan.loan_status}"
    html << " / Lock Status: #{loan.loan_general.try(:additional_loan_datum).try(:pipeline_lock_status_description)}" if loan.loan_general.try(:additional_loan_datum).try(:pipeline_lock_status_description).presence
    html
  end

  def loan_lock_header_field(loan)
    unless %w(Closed Funded).include?(loan.loan_status) or loan.try(:loan_general).try(:lock_price).nil?
      lp = loan.loan_general.lock_price
      html = ''
      html << "Lock Date: #{lp.locked_at.strftime('%m/%d/%Y')}" if lp.locked_at
      html << " / Lock Period: #{lp.lock_period}" if lp.lock_period
      html << " / Lock Expiration Date: #{loan.lock_expiration_at.strftime('%m/%d/%Y')}" if lp.lock_expired_at
      html
    else
      "Not Locked"
    end
  end

  # Used in Core views
  def branch_names emp
    names = ''
    emp.branches.where(channel: Channel.retail_all_ids).each do |branch|
    # emp.multi_institutions.each do |mi|
      names << "#{link_to branch.branch_name, core_institution_path(branch)}<br>"
    end
    names
  end

  def branch_address branch
    raw "#{branch.address}<br />#{branch.city}, #{branch.state} #{branch.zip}"
  end

  def ulti_pro_num emp
    if emp.branches.empty?
      nil
    else
      profile = emp.current_profile_for_branch(emp.branches.last.id)
      profile.ultipro_emp_id if profile
    end
  end
  # Used in Core views
end
