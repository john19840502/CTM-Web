module Esign

  class PopulatePackageVersions
    include ServiceObject

    def call
      Rails.logger.info "Starting to gather Esign event listings"
      ts1 = Time.now
      listings_response = DocMagic::EventListingRequest.for_date_range(1.day.ago, Time.now).execute
      Rails.logger.info "Acquired #{listings_response.listings.size} Esign event listings"
      listings_response.listings.each do |l|
        version = Esign::EsignPackageVersion.new version_hash(l)
        version.save if version.valid?
      end
      ts2 = Time.now
      Rails.logger.info "Elapsed time #{ts2 - ts1} ms"
    end

    private

    def version_hash listing
      { version_number: listing.version_id, external_package_id: listing.package_id.to_i, 
        loan_number: listing.loan_number.to_i, package_type: listing.package_type, 
        package_status: listing.package_status_type, respa_status: listing.respa_status_type, 
        version_date: listing.create_date}
    end

  end

end