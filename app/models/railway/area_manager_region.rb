class AreaManagerRegion < DatabaseRailway
  belongs_to :region
  belongs_to :area_manager, class_name: 'DatamartUser', foreign_key: :datamart_user_id

  validates :region, :area_manager, presence: true
  validate :reassign_area_manager

  # grab the area managers by a named region
  scope :by_region, lambda { |region_name| {:joins => :region, :conditions => { :region => {:name => region_name}}}}

  def to_label
    "#{area_manager}"
  end

  private

  def reassign_area_manager
    return if area_manager.blank? || region.blank?

    ir = AreaManagerRegion.where(datamart_user_id: area_manager).first

    return unless ir
    old_region_name = ir.region.name
    old_region_id = ir.region_id

    errors.add(:area_manager, "must be deleted from a #{old_region_name} Region before it can be added to #{region.name}") unless old_region_id.eql?(region.id)
    errors.add(:area_manager, "is already assigned to #{old_region_name} Region") if old_region_id.eql?(region.id)
    return false
  end
end
