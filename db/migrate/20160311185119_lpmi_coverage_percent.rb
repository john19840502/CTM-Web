class LpmiCoveragePercent < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        CREATE TABLE smds.lpmi_coverage_percent_values (
          id int,
          amortization_term_min int,
          amortization_term_max int,
          ltv_min DECIMAL(8,4),
          ltv_max DECIMAL(8,4),
          lpmi_coverage_percent DECIMAL(8,4)
          )
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        DROP TABLE smds.lpmi_coverage_percent_values
      SQL
    end
  end
end
