class LowestFicoScore
  attr_reader :fico_scores

  def initialize(fico_scores)
    @fico_scores = Array(fico_scores).flatten
    raise "fico_scores should be an array of values" if !@fico_scores.is_a?(Array)
  end

  def call
    calculate
  end

  def calculate
    fico_scores.empty? ? 0 : fico_scores.collect!{|fico_score| fico_score.to_i}.min
  end
end
