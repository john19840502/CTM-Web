module DocMagic

  class SignerAction

    attr_accessor :signer_id, :consent_approved_date, :signer_id_number, :start_date,
                  :completed_date

    def initialize action_hash
      Rails.logger.debug action_hash
      self.signer_id = action_hash["signerID"]
      self.signer_id_number = action_hash["SignerIdentifier"]
      self.consent_approved_date = action_hash["ConsentApprovedDate"].try!(:to_time)
      self.start_date = action_hash["StartDate"].try!(:to_time)
      self.completed_date = action_hash["CompletedDate"].try!(:to_time)
    end

  end

end