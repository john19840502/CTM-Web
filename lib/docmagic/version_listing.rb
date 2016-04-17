module DocMagic

  class VersionListing

    attr_accessor :respa_status_type, :active, :package_status_type, :package_type,
                  :signature_enabled, :create_date, :loan_number, :system_id, :package_id,
                  :version_number, :package_url

    def initialize version_hash
      @respa_status_type = version_hash["RESPAStatusType"]
      @active = version_hash["activeIndicator"] == "true"
      @package_status_type = version_hash["packageStatusType"]
      @package_type = version_hash["packageType"]
      @signature_enabled = version_hash["signatureEnabledIndicator"]
      @create_date = version_hash["CreateDate"].try!(:to_time)
      @loan_number = version_hash["OriginatorReferenceIdentifier"]
      @system_id = version_hash["OriginatorSystemIdentifier"]
      @package_id = version_hash["PackageIdentifier"]
      @version_number = version_hash["VersionIdentifier"].to_i
      @package_url = version_hash["PackageURL"]
    end

  end

end