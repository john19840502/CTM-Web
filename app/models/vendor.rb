class Vendor < ActiveRecord::Base
  attr_accessible :name

  has_many :retail_states, class_name: "StateTitleVendor", foreign_key: "retail_vendor_id"
  has_many :wholesale_states, class_name: "StateTitleVendor", foreign_key: "wholesale_vendor_id"

end
