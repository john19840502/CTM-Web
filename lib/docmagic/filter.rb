module DocMagic

  class Filter

    def self.by_most_recent_package_version listing_array
      listing_array.select{|listing| is_latest_for_loan?(listing, listing_array)}
    end

    private

    def self.is_latest_for_loan? listing, listing_array
      listing_array.select{|l| l.loan_number == listing.loan_number && l.version_id > listing.version_id}.empty?
    end

  end

end