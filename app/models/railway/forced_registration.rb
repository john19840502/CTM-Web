class ForcedRegistration < DatabaseRailway

  #note that an item's comment / user_action can only be edited by the one it is assigned to.  At the moment we 
  #don't give front end users the option to edit if it isn't assigned to them.  Should that change, we'll want to
  #add a validation of some sort to the model

  validates :loan_num, uniqueness: true
  validates :comment, presence: true, on: :update, if: :comment_required?

  scope :current_items, ->{ where("visible = 1") }
  scope :keep_updated, ->{ where(:loan_status => STATUSES_TO_KEEP_UPDATED) }

  before_update :hide_from_view, if: "should_hide?"

  has_many :comments, primary_key: 'loan_num', foreign_key: 'loan_num', class_name: 'ForcedRegistrationCommentHistory', autosave: true

  attr_accessible :loan_num, :borrower, :loan_officer, :disclosure_date, :intent_to_proceed_date, :loan_status, 
                  :visible, :channel, :product_name, :lo_contact_number, :lo_contact_email, :branch, :state,
                  :area_manager, :institution, :assigned_to, :comment, :user_action, :id,
                  :sent_intent_to_proceed_notice, :sent_forced_registration_warning

  def disclosure_age
    (Date.today - Date.parse(disclosure_date.strftime('%m/%d/%Y'))).to_i
  end

  def intent_age
    (Date.today - Date.parse(intent_to_proceed_date.strftime('%m/%d/%Y'))).to_i
  end

  def comment_required?
    user_action.downcase.in?(COMMENT_REQUIRED_ACTIONS)
  end

  def should_hide?
    user_action.downcase.in?(ACTIONS_TO_HIDE)
  end

  def hide_from_view
    self.visible = false
    true
  end

  def updated_values_to_s
    changed_values = []
    self.changed.each do |field|
      changed_values << "#{field} changed from #{self.send("#{field}_was")} to #{self.send("#{field}")}"
    end

    changed_values.join(" and ")
  end

  def can_send_intent_to_proceed_notice?
    !sent_intent_to_proceed_notice
  end

  def can_send_forced_registration_warning?
    !sent_forced_registration_warning
  end

  private

  COMMENT_REQUIRED_ACTIONS  = ['consent withdrawn','contacted lo']
  ACTIONS_TO_HIDE           = ['consent withdrawn']
  STATUSES_TO_KEEP_UPDATED  = ['File Received', 'New', 'Imported', 'In Process']
end
