module Esign

  class EsignSignatureLine < ActiveRecord::Base
    belongs_to :esign_document
    belongs_to :esign_signer

  end

end