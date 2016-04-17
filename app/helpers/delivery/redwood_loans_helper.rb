module Delivery::RedwoodLoansHelper
  def content_or_nil(content)
    content.presence || {'xsi:nil' => 'true'}
  end
end
