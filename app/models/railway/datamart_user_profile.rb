class DatamartUserProfile < DatabaseRailway
  belongs_to :datamart_user
  belongs_to :branch_employee, foreign_key: :datamart_user_id
  belongs_to :branch, class_name: 'Institution', foreign_key: :institution_id

#  attr_accessible :datamart_user_id, :institution_id, :title, :preferred_first_name, :ultipro_emp_id, :effective_date

  validates :datamart_user_id, :effective_date, presence: true
  validates :effective_date, timeliness: { on_or_after: lambda { (Date.today - 365.days) } }

  validates :effective_date, uniqueness: { scope: :datamart_user_id }

  # after_initialize do
  #   if self.new_record?
  #     profiles = DatamartUserProfile.where(datamart_user_id: self.datamart_user_id).pluck(:ultipro_emp_id).uniq
  #   raise 'asd'

  #     self.ultipro_emp_id = profiles[0] unless profiles.empty? || self.ultipro_emp_id.present?
  #   end
  # end

  # after_save do
  #   DatamartUserProfile.where(datamart_user_id: self.datamart_user_id).update_all(ultipro_emp_id: self.ultipro_emp_id) if self.ultipro_emp_id_changed?
  # end
end
 
