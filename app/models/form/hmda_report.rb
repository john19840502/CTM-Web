class HmdaReport < FormtasticFauxBase
  attr_accessor :from_date, :to_date

  validates :from_date, :to_date, :presence => true

  # self.types = {
  #   :newsletter_opt_in => :boolean,
  # }
end