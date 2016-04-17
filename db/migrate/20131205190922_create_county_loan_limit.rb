class CreateCountyLoanLimit < ActiveRecord::Migration
  def change    
    create_table :county_loan_limits do |t|
      t.integer :msa_code
      t.integer :metropolitan_division_code
      t.string  :msa_name 
      t.string  :soa_code 
      t.string  :limit_type 
      t.integer :median_price
      t.integer :limit_for_1_living_unit
      t.integer :limit_for_2_living_units
      t.integer :limit_for_3_living_units
      t.integer :limit_for_4_living_units
      t.string  :state_abbreviation 
      t.integer :county_code_fips
      t.string  :state_name 
      t.string  :county_name 
      t.datetime  :county_transaction_date
      t.datetime  :limit_transaction_date
      t.integer :median_price_determining_limit
      t.integer :year_for_median_determining_limit
    end

    add_index :county_loan_limits, :state_abbreviation
    add_index :county_loan_limits, :county_name
  end
end
