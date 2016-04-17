module DocMagic

  class PackageInfo

    attr_accessor :package_type, :package_status_type, :respa_status_type, :signature_enabled,
                  :application_date, :create_date, :loan_number, :system_id, :package_id,
                  :package_url, :version_id

    def initialize package_hash
      self.package_type = package_hash["packageType"]
      self.package_status_type = package_hash["packageStatusType"]
      self.respa_status_type = package_hash["RESPAStatusType"]
      self.signature_enabled = boolean_if_present package_hash["signatureEnabledIndicator"]
      self.application_date = package_hash["ApplicationDate"].try!(:to_date)
      self.create_date = package_hash["CreateDate"].try!(:to_time)
      self.loan_number = package_hash["OriginatorReferenceIdentifier"]
      self.system_id = package_hash["OriginatorSystemIdentifier"]
      self.package_id = package_hash["PackageIdentifier"]
      self.package_url = url_from package_hash
      self.version_id = package_hash["VersionIdentifier"].to_i
    end

    private

    def boolean_if_present value
      value.nil? ? nil : value.downcase == "true"
    end

    def url_from package_hash
      return package_hash["DocumentListings"]["DocumentPackageURL"] unless package_hash["DocumentListings"].nil?
      package_hash["PackageURL"]
    end

  end

end