module AgentAudit 
  def get_percentage(var1, var2)
    return 0 if var2 == 0
    result = (var1.to_f/var2.to_f) * 100
    result.round(2)
  end

  def audited_name(audited_by)
     User.find(audited_by).try(:display_name) rescue nil
  end

  def branch_manager
    id = loan.loan_general.branch.try(:id) 
    manager_profile = DatamartUserProfile.where{ (institution_id == id) & (effective_date <= Date.today) & (title == 'Branch Manager') }.last 
    return nil if manager_profile.nil?
    manager_profile.branch_employee.try(:name)
  end

  def loan_officer
    loan.account_info.broker_last_name + " " +loan.account_info.broker_first_name rescue nil
  end

  def loan_officer_identifier
    loan.account_info.broker_identifier rescue nil
  end
    
  def channel_name
    FactTranslator.channel_name(self.loan.channel)
  end

  def loan_product_name
    FactTranslator.loan_product_name(self.loan.loan_general.product_code)
  end
end
