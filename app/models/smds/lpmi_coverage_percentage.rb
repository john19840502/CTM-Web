class Smds::LpmiCoveragePercentage < DatabaseDatamart

  def self.sqlserver_create_view
    <<-eos
        SELECT  id,
          amortization_term_min ,
          amortization_term_max ,
          ltv_min ,
          ltv_max ,
          lpmi_coverage_percent
      FROM  [CTM].[smds].[lpmi_coverage_percent_values]
    eos
  end

  def self.percent ltv, term
    where('? BETWEEN ltv_min and ltv_max', ltv).where('? BETWEEN amortization_term_min and amortization_term_max', term).first.try!(:lpmi_coverage_percent).to_f
  end
end