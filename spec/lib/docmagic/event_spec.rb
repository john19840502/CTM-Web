require 'spec_helper'
require 'docmagic'

describe DocMagic::Event do

  context ".initialize" do

    it "should read event from hash" do
      hash = {"eventType" => "ViewPackageLogin", "EventDate" => "2016-02-15T07:57:50.000-08:00", 
              "EventTypeDescription" => "Authentication successful", "UserName" => "Mortgage Sample", 
              "NoteDescription" => "Access code entered: 0000", "UserIPAddressValue" => "64.9.216.172"}
      event = DocMagic::Event.new hash
      expect(event.event_type).to eq "ViewPackageLogin"
      expect(event.event_date).to eq "2016-02-15T10:57:50.000-05:00".to_time
      expect(event.event_type_description).to eq "Authentication successful"
      expect(event.user_full_name).to eq "Mortgage Sample"
      expect(event.note_description).to eq "Access code entered: 0000"
      expect(event.user_ip_address).to eq "64.9.216.172"
    end

  end

end