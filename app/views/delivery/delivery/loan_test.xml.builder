xml = Builder::CleanXmlMarkup.new(indent: 2)
xml.instruct!
xml.MESSAGE( :xmlns => "http://www.mismo.org/residential/2009/schemas", "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance") do
  render partial: 'delivery/deal', locals: { loan: @loan, builder: xml }
end
