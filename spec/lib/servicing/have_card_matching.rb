
RSpec::Matchers.define :have_a_card_matching do |card|
  match do |containers|
    containers.any? do |container|
      type_matches(container, card) &&
        type_qualifier_matches(container, card) &&
        cert_identifier_matches(container, card) && 
        count_matches(container, card) &&
        months_matches(container, card) &&
        date_matches(container, card) &&
        expiration_date_matches(container, card) &&
        amount_matches(container, card) &&
        coverage_amount_matches(container, card) &&
        payee_code_prefix_matches(container, card) &&
        payee_code_suffix_matches(container, card) &&
        coverage_code_matches(container, card)
    end
  end

  failure_message do |containers|
    "Expected there to be a card matching #{card}.  " +
      "Actual cards were: \n    #{containers.inspect}"
  end

  def type_matches(container, card)
    return true unless card.has_key?(:type)
    card[:type].to_s == container.type.to_s
  end

  def type_qualifier_matches(container, card)
    return true unless card.has_key?(:type_qualifier)
    card[:type_qualifier].to_s == container.type_qualifier.to_s
  end

  def cert_identifier_matches(container, card)
    return true unless card.has_key?(:certificate_identifier)
    card[:certificate_identifier].to_s == container.certificate_identifier.to_s
  end

  def count_matches(container, card)
    return true unless card.has_key?(:count)
    card[:count].to_s == container.count.to_s
  end

  def months_matches(container, card)
    return true unless card.has_key?(:months)
    card[:months] == container.months
  end

  def date_matches(container, card)
    return true unless card.has_key?(:date)
    card[:date].try(:to_date) == container.date.try(:to_date)
  end

  def expiration_date_matches(container, card)
    return true unless card.has_key?(:expiration_date)
    card[:expiration_date].try(:to_date) == container.expiration_date.try(:to_date)
  end

  def amount_matches(container, card)
    return true unless card.has_key?(:amount)
    numbers_match? card[:amount], container.amount, '9(9)v9(2)'
  end

  def coverage_amount_matches(container, card)
    return true unless card.has_key?(:coverage_amount)
    card[:coverage_amount] == container.coverage_amount
  end

  def payee_code_prefix_matches(container, card)
    return true unless card.has_key?(:payee_code_prefix)
    card[:payee_code_prefix].to_s == container.payee_code_prefix.to_s
  end

  def payee_code_suffix_matches(container, card)
    return true unless card.has_key?(:payee_code_suffix)
    card[:payee_code_suffix].to_s == container.payee_code_suffix.to_s
  end

  def coverage_code_matches(container, card)
    return true unless card.has_key?(:coverage_code)
    card[:coverage_code] == container.coverage_code
  end

  def strings_match?(a, b)
    a.to_s == b.to_s
  end

  def numbers_match?(a, b, fmt)
    formatter = CobolFormatter.new
    formatter.format(a, fmt) == formatter.format(b, fmt)
  end
end


