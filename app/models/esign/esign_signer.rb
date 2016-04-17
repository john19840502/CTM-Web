module Esign

  class EsignSigner < ActiveRecord::Base
    has_one :esign_borrower_completion
    has_many :esign_signature_lines
    has_many :esign_signer_events

    def esign_completed_date
      esign_signer_events.completed_esign.first.try!(:event_date)
    end

  end

end