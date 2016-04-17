class AddValuesIntoLpmiTable < ActiveRecord::Migration
  def up
    return unless Rails.env.development?
    execute %Q{
      INSERT INTO smds.lpmi_coverage_percent_values VALUES (1, 0, 240, 0.0000, 80.0000, 0.00);
      INSERT INTO smds.lpmi_coverage_percent_values VALUES (2, 0, 240, 80.0001, 85.0000, 6.00);
      INSERT INTO smds.lpmi_coverage_percent_values VALUES (3, 0, 240, 85.0001, 90.0000, 12.00);
      INSERT INTO smds.lpmi_coverage_percent_values VALUES (4, 0, 240, 90.0001, 95.0000, 25.00);
      INSERT INTO smds.lpmi_coverage_percent_values VALUES (5, 0, 240, 95.0001, 200.0000, 35.00);
      INSERT INTO smds.lpmi_coverage_percent_values VALUES (6, 241, 360, 0.0000, 80.0000, 0.00);
      INSERT INTO smds.lpmi_coverage_percent_values VALUES (7, 241, 360, 80.0001, 85.0000, 12.00);
      INSERT INTO smds.lpmi_coverage_percent_values VALUES (8, 241, 360, 85.0001, 90.0000, 25.00);
      INSERT INTO smds.lpmi_coverage_percent_values VALUES (9, 241, 360, 90.0001, 95.0000, 30.00);
      INSERT INTO smds.lpmi_coverage_percent_values VALUES (10, 241, 360, 95.0001, 200.0000, 35.00);
    }
  end

  def down
    return unless Rails.env.development?
    execute %Q{
      DELETE FROM smds.lpmi_coverage_percent_values;
    }
  end
end
