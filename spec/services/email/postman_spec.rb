require 'spec_helper'

describe Email::Postman do

  describe ".call" do

    let(:mail) { OpenStruct.new(to: 'to@email.com', from: 'from@email.com', subject: 'Test subject email') }

    it "should report success" do
      allow(mail).to receive(:deliver)

      expect(Email::Postman.call(mail)).to be_truthy
    end

    [EOFError, Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError].each do |err|
      it "should catch delivery error #{err} and report failure" do
        allow(mail).to receive(:deliver).and_raise(err)
        
        # check for logging and notification
        expect(Airbrake).to receive(:notify)
        expect(Rails.logger).to receive(:error)
        # run last
        expect(Email::Postman.call(mail)).to be_falsey
      end
    end

    it "return valid email address" do
      expect(Email::Postman.choose_valid_email('some_person@sample.com', 'a_good_email@sample.com')).to eql('some_person@sample.com')
      expect(Email::Postman.choose_valid_email('some_person_sample.com', 'a_good_email@sample.com')).to eql('a_good_email@sample.com')
    end

  end
  
end