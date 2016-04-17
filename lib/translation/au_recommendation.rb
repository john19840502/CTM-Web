module Translation
  class AuRecommendation
    attr_accessor :last_submitted_au_recommendation

    def initialize(last_submitted_au_recommendation)
      self.last_submitted_au_recommendation = last_submitted_au_recommendation
    end

    TRANSLATION =
        {
            'EA-I/Ineligible'           => 'EA1',
            'EA-I/Eligible'             => 'EA1',
            'EA-II/Ineligible'          => 'EA2',
            'EA-II/Eligible'            => 'EA2',
            'EA-III/Ineligible'         => 'EA3',
            'EA-III/Eligible'           => 'EA3'
        }

    def translate
      TRANSLATION[last_submitted_au_recommendation] || '   '
    end
  end
end