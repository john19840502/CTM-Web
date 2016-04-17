class Subdomain < DatabaseRailway
  # has_and_belongs_to_many :groups
  has_many :navigations
  
  validates :name, presence: true, uniqueness: true
  
  after_create do |record|
    Navigation.create(name: record.name, path:'root_path', subdomain: record)
  end
  
end
