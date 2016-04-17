class BoardingFile < DatabaseRailway

  attr_accessible :name

  has_attached_file :bundle
  #validates_attachment :txt, :content_type => { content_type: ["text/plain"] }
  do_not_validate_attachment_file_type :bundle

  validates_attachment_content_type :bundle, content_type: ["text/plain"]

  has_many :loan_boardings, autosave: true, dependent: :destroy
  has_many :loans, through: :loan_boardings
  belongs_to :job_status, class_name: 'JobStatus::JobStatus'

  def board loan
    loan_boardings.build loan: loan
  end
end
