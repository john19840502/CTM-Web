module Esign

  class EventDetailsController < RestrictedAccessController

    helper "esign/document_listings"

    def show
      request = DocMagic::EventDetailRequest.new params[:id]
      response = request.execute
      @events = response.events
      @signers = response.signers
      @signer_actions = response.signer_actions
      @package_info = response.package_info
      @document_listings = response.listings
      @version_listings = response.versions
    end

  end

end