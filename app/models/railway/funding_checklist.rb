class FundingChecklist < Checklist
  include Filterable

  has_one :loan_general, through: :loan
  has_one :funding_data, through: :loan_general

  scope :completed, lambda { |status| where(completed: status)}
  scope :between_dates, lambda { |start_date, end_date| where(:created_at => start_date..end_date)}

  def created_by_user_name 
    user_name(self.created_by)
  end

  def completed_by_user_name
    return user_name(self.completed_by) if completed
    ''
  end

  def completion_date
    return updated_at.to_date if completed
    ''
  end
  
  def elapsed_time
    return '' if !completed
    business_days = 0
    date1 = self.created_at.to_date
    date = self.updated_at.to_date
    while date > date1
     business_days = business_days + 1 unless date.saturday? or date.sunday? or date.holiday?(:us)
     date = date - 1.day
    end
    day = (business_days > 1) ? 'days' : 'day'
    "#{business_days} #{day}"
  end

  private

  def user_name user_uuid
    User.find(user_uuid).try!(:display_name)
  end
end