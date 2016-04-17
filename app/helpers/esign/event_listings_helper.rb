module Esign::EventListingsHelper

  def detail_path
    url_escaped_href = esign_event_detail_path('{{listing.package_id}}')
    URI::unescape(url_escaped_href)
  end

  def document_path
    url_escaped_href = esign_document_path('{{listing.package_id}}', :pdf)
    URI::unescape(url_escaped_href)
  end

  

end
