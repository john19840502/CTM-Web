module Esign::DocumentListingsHelper

  def signer_name signer_id
    return "[Not yet signed]" if signer_id.nil? || @signers.blank?
    signer = @signers.select{|s| s.signer_id == signer_id}.first
    signer.nil? ? "[Unknown User: #{signer_id}]" : signer.full_name
  end

end
