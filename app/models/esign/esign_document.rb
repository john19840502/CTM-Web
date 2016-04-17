module Esign
  
  class EsignDocument < ActiveRecord::Base
    has_many :esign_signature_lines
    
  end

end