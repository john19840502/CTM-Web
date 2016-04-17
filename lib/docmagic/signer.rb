module DocMagic

  class Signer

    attr_accessor :signer_id, :email, :first_name, :last_name, :full_name, :token_id, 
                  :uri, :verification_irs_4506_uri

    def initialize signer_hash
      self.signer_id = signer_hash["signerID"]
      self.email = signer_hash["EmailValue"]
      self.first_name = signer_hash["FirstName"]
      self.last_name = signer_hash["LastName"]
      self.full_name = signer_hash["FullName"]
      self.token_id = signer_hash["TokenIdentifier"]
      self.verification_irs_4506_uri = signer_hash["VerificationIRS4506URI"]
      self.uri = signer_hash["SignerURI"]
    end

  end

end