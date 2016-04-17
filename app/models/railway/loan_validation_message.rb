class LoanValidationMessage < DatabaseRailway
  has_many :validation_alerts

  validates :msg_text, :msg_type, presence: true

  def self.get_rule_id txt, msg_type
    msg = self.where(msg_text: txt, msg_type: msg_type).first_or_create!

    msg.id
  end
end
