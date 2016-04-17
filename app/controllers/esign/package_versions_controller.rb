module Esign

  class PackageVersionsController < ApplicationController

    def most_recent_for_loan
      package_version = Esign::EsignPackageVersion.most_recent_for_loan(params[:loan_num])
      @package_id = package_version.external_package_id
    end

  end

end