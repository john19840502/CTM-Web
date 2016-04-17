# A simple wrapper for dates or times to deal with the oddity of dates from Avista.
# Use like this:
#
# CTM::AvistaDate.new(Date.today)
# CTM::AvistaDate.new(Time.now)
module CTM
  class AvistaDate < SimpleDelegator
    def real?
      present? && year != 1900 # sometimes missing dates are stored as 01/01/1900
    end
  end
end