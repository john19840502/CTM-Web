class CreatePurchasedLoans < ActiveRecord::Migration
  def change
    create_table :purchased_loans do |t|
      t.string :cpi_number
      t.integer :basis_code
      t.string :original_balance
      t.string :current_balance
      t.string :original_rate
      t.string :current_rate
      t.string :index
      t.integer :term
      t.integer :amortization_term
      t.integer :ioterm
      t.string :original_p_and_i
      t.string :current_p_and_i
      t.string :escrow_payment
      t.integer :origination_year
      t.integer :origination_month
      t.integer :origination_day
      t.integer :first_pay_date_year
      t.integer :first_pay_date_month
      t.integer :first_pay_date_day
      t.integer :maturity_year
      t.integer :maturity_month
      t.integer :maturity_day
      t.integer :next_due_year
      t.integer :next_due_month
      t.integer :next_due_day
      t.integer :times_deliquent
      t.string :property_value
      t.string :purchase_price
      t.string :first_name
      t.string :last_name
      t.string :name
      t.string :social_security
      t.string :address
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :county
      t.integer :loan_purpose
      t.integer :property_type
      t.integer :number_of_units
      t.integer :occupancy_code
      t.string :documentation
      t.string :credit_grade
      t.integer :credit_score
      t.integer :pmi_code
      t.integer :pmi_level
      t.integer :group_number
      t.string :ltv_ratio
      t.string :cltv_ratio
      t.integer :age
      t.integer :months_to_expect_maturity
      t.integer :months_to_stated_maturity
      t.string :margin
      t.string :first_cap
      t.string :ata_max
      t.string :life_cap
      t.string :life_floor
      t.string :orig_rate_chg_year
      t.string :orig_rate_chg_month
      t.string :orig_rate_chg_day
      t.string :interest_rate_chg_year
      t.string :interest_rate_chg_month
      t.string :interest_rate_chg_day
      t.string :months_to_roll
      t.string :initial_rate_frequency
      t.string :rate_adjustment_frequency
      t.string :convertible
      t.string :channels
      t.string :mi_certificate_id
      t.string :mers_flag
      t.string :mers_number
      t.string :back_end_ratio
      t.string :front_end_ratio
      t.string :self_employed
      t.integer :deal_year
      t.string :deal_abbreviation
      t.integer :product_code
      t.string :market_type_description
      t.string :asset_verification_flag
      t.integer :appraisal_type
      t.string :leasehold_flag
      t.integer :buydown_code
      t.string :npcscrubbed
      t.string :cashoutpurpscrubbed
      t.string :indexvaluevalidated
      t.string :custodydatavalidated
      t.string :wholesalefulldocsisavalida
      t.string :pointsandfeestestyn
      t.string :firsttimehomebuyer
      t.string :appraisaltype
      t.string :currentactualupb
      t.string :actualnextduedate
      t.integer :income_in_thousands
      t.string :coborrower_name
      t.integer :coborrower_ss
      t.string :reserves
      t.string :assets_after_close
      t.string :tot_verified_assets
      t.integer :current_fico
      t.string :other_fin
      t.string :arm_lookback
      t.string :foreign_mail_addr
      t.string :prm_borr_mail_addr
      t.string :prm_borr_mail_city_ste_zip
      t.integer :loantype
      t.integer :proptype
      t.integer :purpose
      t.integer :occupancy
      t.integer :preapprv
      t.date :dispdate
      t.integer :appetnic
      t.integer :cppetnic
      t.integer :apprace1
      t.integer :apprace2
      t.integer :apprace3
      t.integer :apprace4
      t.integer :apprace5
      t.integer :apprace5
      t.integer :cpprace1
      t.integer :cpprace2
      t.integer :cpprace3
      t.integer :cpprace4
      t.integer :cpprace5
      t.integer :appgendr
      t.integer :cppgendr
      t.integer :anninc
      t.integer :hoepa_st
      t.integer :hoepa_st
      t.integer :lien_st
      t.integer :match

      t.timestamps
    end
  end
end