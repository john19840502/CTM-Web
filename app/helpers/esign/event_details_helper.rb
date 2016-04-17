module Esign::EventDetailsHelper

  def actions_for_signer signer_id
    @signer_actions.select{|sa| sa.signer_id == signer_id}
  end

  def date_time time
    time.try(:strftime, "%m/%d/%Y %I:%M %p")
  end

end