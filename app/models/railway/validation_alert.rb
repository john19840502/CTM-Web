class ValidationAlert < DatabaseRailway
  # belongs_to :user
  belongs_to :loan
  belongs_to :loan_validation_message, foreign_key: :rule_id

  validates :user_id, :loan_id, :rule_id, :text, :reason, :action, presence: true

  def as_json(options = nil)
    super(options).merge(user_name: user_name)
  end

  def user_name
    begin
      User.find(self.user_id).try(:display_name)
    rescue ActiveResource::ResourceNotFound
      "User not found"
    end  
  end
end
