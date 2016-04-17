require 'spec_helper'
require 'docmagic'

describe DocMagic::Signer do

  describe ".initialization" do

    it "should extract values from event detail hash" do
      hash = {"signerID" => "S_124537", "EmailValue" => "hpaholak@mbmortgage.com",
              "FirstName" => "Diane", "FullName" => "Diane Sample", "LastName" => "Sample",
              "TokenIdentifier" => "AWdXNFw9WjoBMFNn", "SignerURI" => "/webservices/esign/api/v2/packages/71210/signers/S_124537"}
      signer = DocMagic::Signer.new hash
      expect(signer.signer_id).to eq "S_124537"
      expect(signer.email).to eq "hpaholak@mbmortgage.com"
      expect(signer.first_name).to eq "Diane"
      expect(signer.last_name).to eq "Sample"
      expect(signer.full_name).to eq "Diane Sample"
      expect(signer.token_id).to eq "AWdXNFw9WjoBMFNn"
      expect(signer.verification_irs_4506_uri).to be_nil
      expect(signer.uri).to eq "/webservices/esign/api/v2/packages/71210/signers/S_124537"
    end

    it "should extract values from signer token hash" do
      hash = {"signerID" => "S_124373", "EmailValue" => "hpaholak@mbmortgage.com",
              "FirstName" => "Mortgage", "LastName" => "Sample", "FullName" => "Mortgage Sample",
              "TokenIdentifier" => "UzVRMlY3UzUANVVl", "VerificationIRS4506URI" => "/webservices/esign/api/v2/packages/71128/signers/S_124373/verifications/IRS4506"}
      signer = DocMagic::Signer.new hash
      expect(signer.signer_id).to eq "S_124373"
      expect(signer.email).to eq "hpaholak@mbmortgage.com"
      expect(signer.first_name).to eq "Mortgage"
      expect(signer.last_name).to eq "Sample"
      expect(signer.full_name).to eq "Mortgage Sample"
      expect(signer.token_id).to eq "UzVRMlY3UzUANVVl"
      expect(signer.verification_irs_4506_uri).to eq "/webservices/esign/api/v2/packages/71128/signers/S_124373/verifications/IRS4506"
      expect(signer.uri).to be_nil
    end

  end

end