class RedwoodExport < DatabaseRailway
  include AASM
  include Noteable
  
  #####
  # Validations
  #####
  validates_uniqueness_of :name
  
  
  #####
  # Associations
  #####
  
  has_many :redwood_events
  has_many :loans, :through => :redwood_events
  
  
  ####
  # Callbacks
  ####
  before_validation do |record|
    record.name = ["CTM_RedwoodLoansFile",  I18n.l(DateTime.now, :format => :report_compact)].join('_') unless !!name
    record.status = 'created' unless !!status
  end
  
  after_create do |record|
    record.schedule!
    record.save
    record.write_note "Created Redwood Export Process"
  end
  
  ####
  # Paperclip
  ####
  has_attached_file :xml
  
  
  #####
  # State Machine
  #####
  aasm :column => :status do
    state :created
    state :scheduled,    :enter => :schedule_delayed_job
    state :processing
    state :failed
    state :completed
    
    event :schedule do
      transitions :to => :scheduled, :from => [:created, :failed]
    end
    
    event :process do
      transitions :to => :processing, :from => [:scheduled, :processing]
    end
    
    event :fail do
      transitions :to => :failed, :from => [:created, :processing]
    end
    
    event :complete do
      transitions :to => :completed, :from => :processing
    end
  end
  
  ####
  # AASM Methods
  ####
  def schedule_delayed_job
    self.process_job
    self.write_note "Scheduled delayed job"
  end
  
  
  ####
  # Asynchronous Methods
  ####
  def process_job
    require 'tempfile'
    
    # This is handled in a delayed fashion - move the status
    # of the process to 'processing' status so that the UI shows this
    self.process!
    self.save
    
    
    xml = generate_xml
    
    # Attach the generated XML to the object
    

    file = Tempfile.new("#{self.name}.xml")
    file.write(xml)
    
    self.xml = file
    
    
    
    
    # Determine if it was successful
    if !!xml
      self.complete!
    else
      self.fail!
      # Write a note as to why we failed
    end
  end
  handle_asynchronously :process_job, :priority => 100 # Lower numbers have priority
  
  
  
  def generate_xml
    xml = "<note>
    <to>#{Time.now.to_s}</to>
    <from>Jani</from>
    <heading>Reminder</heading>
    <body>Don't forget me this weekend!</body>
    </note>"

    # Logic here to return false if there was a problem
    return xml
  end
  
end
