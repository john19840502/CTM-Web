class StateTitleVendor < ActiveRecord::Base
  include ProvinceCode

  attr_accessible :retail_vendor_id, :wholesale_vendor_id
  attr_readonly :state

  belongs_to :retail_vendor, class_name: "Vendor"
  belongs_to :wholesale_vendor, class_name: "Vendor"

  validates :state, uniqueness: true, presence: true
  validates :retail_vendor_id, presence: true
  validates :wholesale_vendor_id, presence: true

  def state_full_name
    province_for_code state
  end
end
