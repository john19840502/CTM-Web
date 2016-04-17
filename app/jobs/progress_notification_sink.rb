
class ProgressNotificationSink

  def initialize job_status
    self.job_status = job_status
  end

  def notify progress
    return unless job_status
    job_status.progress = progress
    job_status.save!
  end

  private

  attr_accessor :job_status
end
