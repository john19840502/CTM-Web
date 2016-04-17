require 'exception_formatter'
module Servicing
  class AttachFileBaseJob
    attr_accessor :attachment_target
    attr_accessor :progress_sink

    def initialize attachment_target
      self.attachment_target = attachment_target
      self.progress_sink = ProgressNotificationSink.new attachment_target.job_status
    end

    def perform
      begin
        start
        data = create_attachment
        attach_file data
        complete
      rescue Exception => e
        Rails.logger.error "oops, error in background job: #{ExceptionFormatter.new e}"
        fail e
        raise e   # re-raise so that the delayed job actually fails.  Not sure about this...
      end
    end

    def create_attachment
      raise "subclasses should implement this"
    end

    def attach_file data
      path = File.expand_path "#{Rails.root}/tmp/boarding_file_generated_#{DateTime.now.strftime('%Y%m%d_%H%M')}.txt"
      File.open(path, "wb") {|file| file.write data}
      attachment_target.update_attribute :bundle, File.open(path)
      attachment_target.save!
      File.delete path
    end

    def start
      attachment_target.job_status.start!
      attachment_target.job_status.save!
    end

    def complete
      attachment_target.job_status.complete!
      attachment_target.job_status.save!
    end

    def fail e
      attachment_target.job_status.fail!
      attachment_target.job_status.error_message = e.message
      attachment_target.job_status.save!
    end
  end
end

