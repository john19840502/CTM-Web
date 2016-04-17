require 'servicing/boarding_file_builder'

module Servicing
  class AttachBoardingFileJob < AttachFileBaseJob
    attr_accessor :boarding_file

    def initialize boarding_file
      self.boarding_file = boarding_file
      super(boarding_file)
    end

    def create_attachment
      Servicing::BoardingFileBuilder.new(progress_sink).build boarding_file
    end
  end
end

