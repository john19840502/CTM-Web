BusinessTime::Config.load("#{Rails.root}/config/business_time.yml")

Holidays.between(2.years.ago, 2.years.from_now, :us).map do |holiday|
  BusinessTime::Config.holidays << holiday[:date]
end

# or you can configure it manually:  look at me!  I'm Tim Ferris!
#  BusinessTime.Config.beginning_of_workday = "10:00 am"
#  BusinessTime.Comfig.end_of_workday = "11:30 am"
#  BusinessTime.config.holidays << Date.parse("August 4th, 2010")
