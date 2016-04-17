class UwRegistrationValidation < DatabaseRailway
  # belongs_to :user
  belongs_to :loan

  attr_accessible :user_id, :loan_id, :signature_1003_date, :most_recent_imaged_gfe_date, :initial_imaged_ctm_gfe_date,
      :til_signature_date_from_image, :prior_apr

  validates :user_id, :loan_id, presence: true

  def self.save params
    uw = UwRegistrationValidation.where(user_id: current_user.uuid, loan_id: params[:lid]).first_or_initialize

    uw.signature_1003_date = params[:signature_1003_date]
    uw.most_recent_imaged_gfe_date = params[:most_recent_imaged_gfe_date]
    uw.initial_imaged_ctm_gfe_date = params[:initial_imaged_ctm_gfe_date]
    uw.til_signature_date_from_image = params[:til_signature_date_from_image]
    uw.prior_apr = params[:prior_apr]
    uw.lock = lock

    uw.save!
    uw
  end
end
