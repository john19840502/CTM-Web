class BrokerCompModeler <  DatabaseRailway

  belongs_to :loan
  
  def update_from_params(params)
  
    self.total_broker_comp_gfe = params[:total_gfe_broker_comp]
    self.user_comments = params[:user_comments]
    if self.user_comments_changed?
      self.modeler_date_time = "#{Time.now.strftime('%m/%d/%Y %r')}" unless self.user_comments.blank?
      self.modeler_user = "#{current_user.display_name}" unless self.user_comments.blank?
    end

    self.save
  end

  
end
