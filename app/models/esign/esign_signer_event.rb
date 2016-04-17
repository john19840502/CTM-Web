module Esign

  class EsignSignerEvent < ActiveRecord::Base
    belongs_to :esign_signer

    scope :completed_esign, -> {where(event_type: "CompleteEsign")}
    
  end

end