module DocMagic

  class Event

    attr_accessor :event_type, :event_date, :event_type_description, :user_full_name,
                  :note_description, :user_ip_address

    def initialize event_hash
      self.event_type = event_hash["eventType"]
      self.event_date = event_hash["EventDate"].try!(:to_time)
      self.event_type_description = event_hash["EventTypeDescription"]
      self.user_full_name = event_hash["UserName"]
      self.note_description = event_hash["NoteDescription"]
      self.user_ip_address = event_hash["UserIPAddressValue"]
    end

  end

end