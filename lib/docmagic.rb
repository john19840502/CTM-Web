module DocMagic
  # REQUESTS
  autoload :Request, 'docmagic/request'
  autoload :AuthenticatedRequest, 'docmagic/authenticated_request'
  autoload :EventListingRequest, 'docmagic/event_listing_request'
  autoload :EventDetailRequest, 'docmagic/event_detail_request'
  autoload :DocumentRequest, 'docmagic/document_request'
  autoload :EventSignerTokenRequest, 'docmagic/event_signer_token_request'
  autoload :AuthenticationRequest, 'docmagic/authentication_request'
  autoload :AuthenticationToken, 'docmagic/authentication_token'

  # MODELS
  autoload :Signer, 'docmagic/signer'
  autoload :SignerAction, 'docmagic/signer_action'
  autoload :DocumentListing, 'docmagic/document_listing'
  autoload :DocumentMark, 'docmagic/document_mark'
  autoload :Event, 'docmagic/event'
  autoload :PackageInfo, 'docmagic/package_info'
  autoload :VersionListing, 'docmagic/version_listing'

  # HELPERS
  autoload :Filter, 'docmagic/filter'
end