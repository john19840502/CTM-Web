# Used require_or_load here b/c I was getting uninitialized 
# constant on the *second* page load.  Just like this:
# http://stackoverflow.com/questions/2796465/first-call-to-a-controller-constant-is-defined-second-call-uninitialized-con
#  - Greg
require_or_load 'lar_file_importer'

class LoanComplianceEventUpload < DatabaseRailway
  attr_accessible :user_uuid, :hmda_loans, :job_status, :month, :year
  has_attached_file :hmda_loans

  belongs_to :job_status, class_name: 'JobStatus::JobStatus'
  has_many :loan_compliance_events
  has_many :periods, class_name: "LoanComplianceEventUploadPeriod"

  # validates :month, :year, numericality: { only_integer: true, greater_than: 0, message: 'must be selected' }, allow_nil: false, allow_blank: false

  validates_attachment_presence :hmda_loans
  do_not_validate_attachment_file_type :hmda_loans

  scope :incomplete, lambda { |user| joins(:job_status).where{(job_status.status != 'completed') & (user_uuid == user.uuid)} }
  def period_names
    periods.map(&:period_name).join(' & ')
  end

  def period_dates
    periods.map(&:period_date)
  end

  def add_periods(periods, year)
    Array(periods).each do |p|
      self.periods.new({month: p, year: year}, without_protection: true)
    end
  end

  def process_upload
    begin
      
      start
      
      Compliance::Hmda::LarFileImporter.new(ProgressNotificationSink.new(job_status)).import_file(self)

      message = Notifier.loan_compliance_event_upload_success
      Email::Postman.call message
    
      complete

    rescue => e
      fail e
      message = Notifier.loan_compliance_event_upload_failure(e.message)
      Email::Postman.call message
      raise e
    end
  end
  handle_asynchronously :process_upload, priority: 100

private

  def start
    job_status.start!
    job_status.save!
  end

  def complete
    job_status.complete!
    job_status.save!
  end

  def fail e
    job_status.fail!
    job_status.error_message = e.message
    job_status.save!
  end

end
