class Region < DatabaseRailway

  has_many :area_manager_regions

  def branches
    Institution.where('region_id' => id)
  end
end
