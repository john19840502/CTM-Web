class UwchecklistItem < DatabaseRailway
  include ChecklistDisplayConditions
  
  belongs_to :uwchecklist_section
  
  acts_as_list :scope => :uwchecklist_section
  
  scope :active, ->{ where(:is_active => true) }
  
  def name
    value
  end
end


