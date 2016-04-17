xml = Builder::CleanXmlMarkup.new(indent: 2)
xml.instruct!
xml.MESSAGE(:MISMOReferenceModelIdentifier => "3.0.0.263.12", :xmlns => "http://www.mismo.org/residential/2009/schemas", "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance") do
  render partial: 'delivery/about_versions', locals: { builder: xml, version: "FNM 2.0"}
  xml.DEAL_SETS do
    xml.DEAL_SET do
      xml.DEALS do
        @loans.each do |loan|
          render partial: 'delivery/deal', locals: { loan: loan, builder: xml }
        end
      end
      render partial: 'delivery/parties', locals: { bucket: @delivery, builder: xml }
      render partial: 'pool', locals: { pool: @delivery, builder: xml }
    end
    render partial: 'delivery/file_preparer', locals: { builder: xml }
  end
end
