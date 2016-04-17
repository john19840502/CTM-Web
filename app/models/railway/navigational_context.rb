class NavigationalContext < DatabaseRailway
  # attr_accessible :title, :body

  belongs_to :role
  belongs_to :navigation

end
