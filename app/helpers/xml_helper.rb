module XmlHelper
  def content_or_nil(content)
    content.to_s.strip.presence || {'xsi:nil' => 'true'}
  end
end