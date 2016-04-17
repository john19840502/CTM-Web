class BranchCompensationDetail < DatabaseRailway
  
  belongs_to :branch_compensation

  validates :branch_compensation, :effective_date, :lo_min, :lo_max, presence: true
  validates :effective_date, allow_nil: true, allow_blank: true, timeliness: { on_or_after: lambda { (Date.today - 365.days) } }

  validates :lo_traditional_split, 
            :tiered_split_low, 
            :tiered_split_high, 
            :tiered_amount,
            :branch_min,
            :branch_max,
            :lo_min,
            :lo_max, numericality: { greater_or_equal_to: 0, allow_nil: true, allow_blank: true }

  validates :lo_traditional_split, 
            :tiered_split_low, 
            :tiered_split_high, numericality: { less_than: 100, allow_nil: true, allow_blank: true, message: 'must be less than 100%' }
  
  # Do not require any but if filled in, allow only either or
  validate :require_traditional_split_xor_tiered_split, 
    :unless => Proc.new {|det| (det.lo_traditional_split.blank? and det.tiered_split_low.blank? and det.tiered_split_high.blank?)}

  validates :effective_date, uniqueness: { scope: :branch_compensation_id }

  before_update :prevent_update

  after_find do |record|
    record.lo_traditional_split = record.lo_traditional_split.round(4) if record.lo_traditional_split
    record.tiered_split_low = record.tiered_split_low.round(4) if record.tiered_split_low
    record.tiered_split_high = record.tiered_split_high.round(4) if record.tiered_split_high
    record.tiered_amount = record.tiered_amount.round(2) if record.tiered_amount
  end

  def commission_percentage
    return lo_traditional_split if lo_traditional_split
    return tiered_split_low if tiered_split_low
    0
  end

  def to_label
    "Compensation Plan Details"
  end

  def tiered_split_adjustment
    tiered_split_high.to_f - tiered_split_low.to_f
  end

private

  def require_traditional_split_xor_tiered_split
    errors[:base] << "Can not have Traditional Split and Tiered Split simultaneously" if !(lo_traditional_split.blank? ^ (tiered_split_low.blank? and tiered_split_high.blank?))
  end

  def prevent_update
    return true unless self.branch_compensation_id_changed?
    errors.add(:branch_compensation, "Compensation Plan can not be changed")
    false
  end  
end
