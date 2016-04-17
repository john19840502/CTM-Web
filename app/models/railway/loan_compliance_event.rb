require 'hmda_transformations'

class LoanComplianceEvent < DatabaseRailway
  serialize :exception_history, Hash
  serialize :changed_values, Hash

  #we don't really need protected attributes in this gem because we use strong parameters
  #in the relevant controllers.  But because the protected_attributes gem is installed, we 
  #can't do legit mass assignments (e.g. in tests) unless we whitelist all the attributes.  
  #That is waht this is for.  
  attr_protected :created_at

  belongs_to :loan_general, foreign_key: 'aplnno', primary_key: 'loan_id'
  belongs_to :loan_compliance_event_upload

  has_many :borrowers, foreign_key: 'loan_id', primary_key: 'aplnno'

  before_save :store_current_signature
  after_save :save_changed_values
  after_update :record_changes

  alias_attribute :action, :action_code

  scope :unexported, -> do
    joins(:loan_compliance_event_upload).where('exported_at IS ?', nil).readonly(false)
  end

  def self.reportable_events_between(from, to)
    where { (actdate.in(my{from}..my{to})) & (reportable == true) }.order("aplnno")
  end

  def self.unexported_for_period(range, type)
    for_period(range, type).unexported
  end

  validates :action_code,
    :amort_term,
    :apcrscore,
    :apeth,
    :apprvalue,
    :aprace1,
    :aprace2,
    :aprace3,
    :aprace4,
    :aprace5,
    :apsex,
    :branchid,
    :capcrscore,
    :capeth,
    :caprace1,
    :caprace2,
    :caprace3,
    :caprace4,
    :caprace5,
    :capsex,
    :cash_out,
    :channel,
    :co_apl_age,
    :denialr1,
    :denialr2,
    :denialr3,
    :disc_pnt,
    :doc_type,
    :hoepa,
    :initadjmos,
    :lienstat,
    :lnamount,
    :lnpurpose,
    :lntype,
    :loan_term,
    :marital,
    :maritalc,
    :occupancy,
    :penalty,
    :preappr,
    :proptype,
    :purchtype, numericality: { only_integer: true }, allow_nil: true, allow_blank: true

  validates_date :actdate,
    :apdate,
    :createdate,
    :lockdate, allow_nil: true, allow_blank: true

  validates_datetime :finaldate, allow_nil: true, allow_blank: true

  validates :aplnno, :format => { :with => /\d/i }

  COLUMN_OPTIONS = {
    lntype: [[1, "1"],[2, "2"],[3, "3"],[4, "4"]],
    proptype: [[1, "1"],[2, "2"],[3, "3"]],
    lnpurpose: [[1, "1"],[2, "2"],[3, "3"]],
    occupancy: [[1, "1"],[2, "2"],[3, "3"]],
    preappr: [[1, "1"],[2, "2"],[3, "3"]],
    action_code: [[1, "1"],[2, "2"],[3, "3"],[4, "4"],[5, "5"],[6, "6"],[7, "7"],[8, "8"]],
    apeth: [[1, "1"],[2, "2"],[3, "3"],[5, "5"]],
    capeth: [[1, "1"],[2, "2"],[3, "3"],[5, "5"]],
    apsex: [[1, "1"],[2, "2"],[3, "3"],[5, "5"]],
    capsex: [[1, "1"],[2, "2"],[3, "3"],[5, "5"]],
    aprace1: [[1, "1"],[2, "2"],[3, "3"],[4, "4"],[5, "5"],[6, "6"],[7, "7"],[8, "8"]],
    aprace2: [[1, "1"],[2, "2"],[3, "3"],[4, "4"],[5, "5"],[6, "6"],[7, "7"],[8, "8"]],
    aprace3: [[1, "1"],[2, "2"],[3, "3"],[4, "4"],[5, "5"],[6, "6"],[7, "7"],[8, "8"]],
    aprace4: [[1, "1"],[2, "2"],[3, "3"],[4, "4"],[5, "5"],[6, "6"],[7, "7"],[8, "8"]],
    aprace5: [[1, "1"],[2, "2"],[3, "3"],[4, "4"],[5, "5"],[6, "6"],[7, "7"],[8, "8"]],
    caprace1: [[1, "1"],[2, "2"],[3, "3"],[4, "4"],[5, "5"],[6, "6"],[7, "7"],[8, "8"]],
    caprace2: [[1, "1"],[2, "2"],[3, "3"],[4, "4"],[5, "5"],[6, "6"],[7, "7"],[8, "8"]],
    caprace3: [[1, "1"],[2, "2"],[3, "3"],[4, "4"],[5, "5"],[6, "6"],[7, "7"],[8, "8"]],
    caprace4: [[1, "1"],[2, "2"],[3, "3"],[4, "4"],[5, "5"],[6, "6"],[7, "7"],[8, "8"]],
    caprace5: [[1, "1"],[2, "2"],[3, "3"],[4, "4"],[5, "5"],[6, "6"],[7, "7"],[8, "8"]],
    purchtype: [[1, "1"],[2, "2"],[3, "3"],[4, "4"],[5, "5"],[6, "6"],[7, "7"],[8, "8"],[9, "9"]],
    denialr1: [[1, "1"],[2, "2"],[3, "3"],[4, "4"],[5, "5"],[6, "6"],[7, "7"],[8, "8"],[9, "9"]],
    denialr2: [[1, "1"],[2, "2"],[3, "3"],[4, "4"],[5, "5"],[6, "6"],[7, "7"],[8, "8"],[9, "9"]],
    denialr3: [[1, "1"],[2, "2"],[3, "3"],[4, "4"],[5, "5"],[6, "6"],[7, "7"],[8, "8"],[9, "9"]],
    hoepa: [[1, "1"],[2, "2"]],
    lienstat: [[1, "1"],[2, "2"],[3, "3"],[4, "4"]]
  }
  INPUT_TYPE = {
      reportable: :checkbox,
      actdate: :date,
      apdate: :date,
      createdate: :date,
      lockdate: :date,
      lntype: :select,
      proptype: :select,
      lnpurpose: :select,
      occupancy: :select,
      preappr: :select,
      action_code: :select,
      apeth: :select,
      capeth: :select,
      apsex: :select,
      capsex: :select,
      aprace1: :select,
      aprace2: :select,
      aprace3: :select,
      aprace4: :select,
      aprace5: :select,
      caprace1: :select,
      caprace2: :select,
      caprace3: :select,
      caprace4: :select,
      caprace5: :select,
      purchtype: :select,
      denialr1: :select,
      denialr2: :select,
      denialr3: :select,
      hoepa: :select,
      lienstat: :select
  }

  DISPLAY_WITH = {
    actdate: :l,
    apdate: :l,
    createdate: :l,
    lockdate: :l
  }

  def self.for_period cond, type
    where(cond)
  end

  def self.set_session_period period, year, type
    if type == 'q'
      PurchasedLoan.create_events
      quarterly_events(period, year)
    else
      monthly_events(period, year)
    end 
  end

  def self.quarterly_events period, year
    report_range =  case period.downcase
                      when 'q1'
                        (1..4).to_a
                      when 'q2'
                        (1..7).to_a
                      when 'q3'
                        (1..10).to_a
                      when 'q4'
                        (1..12).to_a
                    end

    "actdate >= '#{Date.new(year.to_i, report_range.first, 1).strftime('%Y-%m-%d')}' and actdate < '#{Date.new(year.to_i, report_range.last, 1).strftime('%Y-%m-%d')}'"   
  end

  def self.monthly_events period, year
    start_date = Date.new(year.to_i, period.first.to_i).beginning_of_month
    end_date = Date.new(year.to_i, period.last.to_i).end_of_month
    "(actdate BETWEEN '#{start_date}' and '#{end_date}')"
  end

  def self.do_transformations period = 'm'
    if period.eql?('m')
      events = self.where(transformed: false)
    else
      events = self.where(period)
    end
    
    events.includes(loan_general: [ :investor_lock ]).find_each do |row|
      Compliance::Hmda::HmdaTransformations.new(row, period).do_transformations
    end
  end

  def self.editable?(column_name)
    !%w(aplnno updated_at last_updated_by).include?(column_name)
  end

  def self.options_for_column(column_name)
    COLUMN_OPTIONS[column_name.to_sym]
  end

  def self.input_type(column_name)
    INPUT_TYPE[column_name.to_sym] || :input
  end

  def self.display_with(column_name)
    DISPLAY_WITH[column_name.to_sym]
  end

  # ============================== !!!!!!!!!!!!!!!!!!!!!!!!!!!!! ===========================
  # THE ORDER OF THIS HASH IS SIGNIFICANT! DO NOT RESORT ON A WHIM
  # THE ORDER OF THIS HASH IS SIGNIFICANT! DO NOT RESORT ON A WHIM
  # THE ORDER OF THIS HASH IS SIGNIFICANT! DO NOT RESORT ON A WHIM

  DICTIONARY = {
    'APLNNO' => :aplnno,
    'APPNAME' => :appname,
    'PROPSTREET' => :propstreet,
    'PROPCITY' => :propcity,
    'PROPSTATE' => :propstate,
    'PROPZIP' => :propzip,
    'APDATE' => :apdate,
    'LNTYPE' => :lntype,
    'PROPTYPE' => :proptype,
    'LNPURPOSE' => :lnpurpose,
    'OCCUPANCY' => :occupancy,
    'LNAMOUNT' => :lnamount,
    'PREAPPR' => :preappr,
    'ACTION' => :action,
    'ACTDATE' => :actdate,
    'MACODE' => :macode,
    'STCODE' => :stcode,
    'CNTYCODE' => :cntycode,
    'CENSUSTRCT' => :censustrct,
    'APETH' => :apeth,
    'CAPETH' => :capeth,
    'APRACE1' => :aprace1,
    'APRACE2' => :aprace2,
    'APRACE3' => :aprace3,
    'APRACE4' => :aprace4,
    'APRACE5' => :aprace5,
    'CAPRACE1' => :caprace1,
    'CAPRACE2' => :caprace2,
    'CAPRACE3' => :caprace3,
    'CAPRACE4' => :caprace4,
    'CAPRACE5' => :caprace5,
    'APSEX' => :apsex,
    'CAPSEX' => :capsex,
    'TINCOME' => :tincome,
    'PURCHTYPE' => :purchtype,
    'DENIALR1' => :denialr1,
    'DENIALR2' => :denialr2,
    'DENIALR3' => :denialr3,
    'APR' => :apr,
    'SPREAD' => :spread,
    'LOCKDATE' => :lockdate,
    'LOAN_TERM' => :loan_term,
    'HOEPA' => :hoepa,
    'LIENSTAT' => :lienstat,
    'QLTYCHK' => :qltychk,
    'CREATEDATE' => :createdate,
    'CHANNEL' => :channel,
    'FINALDATE' => :finaldate,
    'AMORTTYPE' => :amorttype,
    'INITADJMOS' => :initadjmos,
    'APPTAKENBY' => :apptakenby,
    'OCCUPYURLA' => :occupyurla,
    'BRANCHID' => :branchid,
    'BRANCHNAME' => :branchname,
    'INSTITUTIONID' => :institutionid,
    'LOANREP' => :loanrep,
    'LOANREPNAME' => :loanrepname,
    'NOTE_RATE' => :note_rate,
    'PNTSFEES' => :pntsfees,
    'BROKER' => :broker,
    'BROKERNAME' => :brokername,
    'LTV' => :ltv,
    'CLTV' => :cltv,
    'DEBT_RATIO' => :debt_ratio,
    'COMB_RATIO' => :comb_ratio,
    'APCRSCORE' => :apcrscore,
    'CAPCRSCORE' => :capcrscore,
    'PENALTY' => :penalty,
    'LOAN_PROG' => :loan_prog,
    'MARITAL' => :marital,
    'MARITALC' => :maritalc,
    'APL_AGE' => :apl_age,
    'CO_APL_AGE' => :co_apl_age,
    'CASH_OUT' => :cash_out,
    'DOC_TYPE' => :doc_type,
    'AMORT_TERM' => :amort_term,
    'APPRVALUE' => :apprvalue,
    'LENDER_FEE' => :lender_fee,
    'BROKER_FEE' => :broker_fee,
    'ORIG_FEE' => :orig_fee,
    'DISC_PNT' => :disc_pnt,
    'DPTS_DL' => :dpts_dl,
    'HOUSEPRP' => :houseprp,
    'MNTHDEBT' => :mnthdebt,
  }

  def calculate_data_signature
    dump = self.attributes.except('created_at', 'updated_at', 'exception_history', 'reconciled_by', 'reconciled_at', 'original_signature', 
      'current_signature', 'last_updated_by', 'employee_loan', 'reportable', 'comments', 'non_existant_loan', 'transformed', 'changed_values', 
      'loan_compliance_event_upload_id').sort.map do |k,v|
      v = ("%.03f" %  v.to_f) if (k.eql?('apr') and v)
      "#{k}:#{v}"
    end.join(',')
    Digest::SHA1.hexdigest dump
  end

  def store_current_signature
    self.current_signature = calculate_data_signature
  end

  def exception_history_formatted
    eh = self.exception_history
    if eh.present?
        fields = eh.keys.first
        values = eh.values.flatten * ", "
        history = "#{fields} : #{values}"
    end

    return history
  end

  def save_changed_values
    self.changed_values = self.changed_attributes.except('transformed') unless self.new_record?
  end

  def record_changes
    audit_hash = self.changes.except(:current_signature, :updated_at, :created_at, :transformed, :changed_values)
    Mdb::LoanComplianceEventAudit.record_change(self.aplnno, loan_event_changes(audit_hash), current_user) if audit_hash.any?
  end

  def loan_event_changes audit_hash
    [:actdate, :apdate, :createdate, :lockdate, :finaldate].each do |el|
      audit_hash[el] = [transform_date(audit_hash[el][0]), transform_date(audit_hash[el][1])] if audit_hash.has_key?(el)
    end
    audit_hash
  end

  def transform_date dt
    dt.to_time if dt.present?
  end

  def mark_unreportable
    update_attributes(reportable: false)
  end

  def apr
    sprintf("%.3f", super.to_f.round(3))
  end

  def ltv
    sprintf("%.2f", super.to_f.round(2))
  end

  def cltv
    sprintf("%.2f", super.to_f.round(2))
  end

  def debt_ratio
    sprintf("%.3f", super.to_f.round(3))
  end

  def comb_ratio
    sprintf("%.3f", super.to_f.round(3))
  end
end
