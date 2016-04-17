class Smds::GnmaLoan < ::DatabaseDatamart
  self.table_name_prefix += 'smds_'

  def self.primary_key
    'loan_number'
  end

  belongs_to :gnma_pool, :class_name => 'Smds::GnmaPool', foreign_key: :pool_number, primary_key: :pool_number

  belongs_to :master_loan, class_name: 'Master::Loan', foreign_key: 'loan_number', primary_key: 'loan_num'
  has_many :master_borrowers, through: :master_loan, source: :borrowers

  CREATE_VIEW_SQL = <<-eos
    SELECT -- M01 record type
           CLD.InvestorCommitNbr             AS pool_number,
           LEFT(LTRIM(CLD.LnNbr), 15)        AS loan_number,
           CASE
             WHEN UPPER(RTRIM(CLD.ProductCode)) LIKE 'FHA%' THEN REPLACE(CLD.FHACaseNbr, '-', '')
             WHEN UPPER(RTRIM(CLD.ProductCode)) LIKE 'VA%'  THEN REPLACE(CLD.VACaseNbr, '-', '')
             ELSE NULL
           END                               AS case_number,
           CASE
             WHEN UPPER(RTRIM(CLD.ProductCode)) LIKE 'USDA%' THEN 'M'
             WHEN UPPER(RTRIM(CLD.ProductCode)) LIKE 'FHA%'  THEN 'F'
             WHEN UPPER(RTRIM(CLD.ProductCode)) LIKE 'VA%'   THEN 'V'
             ELSE NULL
           END                               AS mortgage_type,
           CLD.FinalNoteRate                 AS interest_rate,
           CLD.[PI]                          AS principal_and_interest,
           CLD.LnAmt                         AS original_principal_amount,
           CLD.UPB                           AS unpaid_principal_balance,
           -- M02 record type
           CLD.FirstPmtDt                    AS first_pay_date,
           CLD.MaturityDt                    AS last_pay_date,
           CLD.CalcAggregateLoanCurtailments AS unscheduled_principal_curtailment,
           NULL                              AS percent_of_increase,
           NULL                              AS mortgage_margin,
           NULL                              AS manufactured_home_type,
           ISNULL(CLD.MERSMomFlg, 'N')       AS mers_original_mortgagee,
           LEFT(LTRIM(CLD.MERS), 18)         AS mers_identification_number,
           -- M03 record type
           LEFT(LTRIM(CLD.PropertyStreetAddress), 40)
                                             AS mortgage_address,
           LEFT(LTRIM(CLD.PropertyCity), 21) AS mortgage_city,
           LEFT(LTRIM(CLD.PropertyState), 2) AS mortgage_state,
           LEFT(LTRIM(RTRIM(CLD.PropertyPostalCode)), 9)
                                             AS mortgage_zip,
           -- M04 record type
           LEFT(LTRIM(CLD.Brw1FName), 25)    AS borrower_first_name,
           LEFT(LTRIM(CLD.Brw1LName), 25)    AS borrower_last_name,
           CLD.Brw1SSN                       AS borrower_ssn,
           CLD.LTV                           AS ltv,
           CLD.LnAppRecdDt                   AS loan_application_date,
           CLD.FirstTimeHomebuyer            AS first_time_homebuyer,
           -- M05 record type
           LEFT(LTRIM(CLD.Brw2FName), 25)    AS coborrower1_first_name,
           LEFT(LTRIM(CLD.Brw2LName), 25)    AS coborrower1_last_name,
           CLD.Brw2SSN                       AS coborrower1_ssn,
           -- M06 record type
           LEFT(LTRIM(CLD.Brw3FName), 25)    AS coborrower2_first_name,
           LEFT(LTRIM(CLD.Brw3LName), 25)    AS coborrower2_last_name,
           CLD.Brw3SSN                       AS coborrower2_ssn,
           -- M07 record type
           LEFT(LTRIM(CLD.Brw4FName), 25)    AS coborrower3_first_name,
           LEFT(LTRIM(CLD.Brw4LName), 25)    AS coborrower3_last_name,
           CLD.Brw4SSN                       AS coborrower3_ssn,
           -- M10 record type
           NULL                              AS loan_key,
           CASE
             WHEN UPPER(RTRIM(CLD.ProductCode)) LIKE 'FHA%'  THEN '1'
             WHEN UPPER(RTRIM(CLD.ProductCode)) LIKE 'VA%'   THEN '2'
             WHEN UPPER(RTRIM(CLD.ProductCode)) LIKE 'USDA%' THEN '3'
             ELSE NULL
           END                               AS loan_type_code,
           CASE UPPER(RTRIM(CLD.LnPurpose))
             WHEN 'PURCHASE'  THEN '1' -- Purchase
             WHEN 'REFINANCE' THEN '2' -- Refinance
             ELSE NULL
           END                               AS loan_purpose,
           CLD.NbrOfUnits                    AS living_units,
           CASE CLD.GiftFlg
             WHEN 'Y' THEN '1' -- Borrower received gift funds for down payment
             ELSE '2'          -- No gift assistance
           END                               AS down_payment_assistance,
           CLD.Brw1CreditScore               AS credit_score,
           CLD.[RepresentativeFICO]          AS representative_fico,
           CASE CLD.BuydownFlg
             WHEN 'Y' THEN '1' -- Buydown loan
             ELSE '2'          -- Not a buydown loan
           END                               AS loan_buydown_code,
           CLD.HUD902MIPAmt                  AS upfront_mortgage_insurance_premium,
           CONVERT(money, CLD.MIPmtAmt * 12) AS annual_mortgage_insurance_premium,
           /*** BEGIN: ARMs Only ***********************************************************/
           NULL                              AS interest_rate_change_date,
           NULL                              AS index_type,
           NULL                              AS acceptable_range,
           NULL                              AS arm_type,
           NULL                              AS initial_cap,
           NULL                              AS subsequent_cap,
           NULL                              AS lifetime_cap,
           /*** END:   ARMs Only ***********************************************************/
           -- M11 record type
           CLD.CLTV                          AS cltv,
           CLD.DTI                           AS dti,
           CASE UPPER(RTRIM(CLD.LnPurpose))
             WHEN 'PURCHASE'  THEN NULL -- Leave blank on a purchase
             WHEN 'REFINANCE' THEN CASE UPPER(RTRIM(CLD.RefPurposeType))
                                     WHEN 'CASHOUTDEBTCONSOLIDATION'         THEN '2' -- Cash Out
                                     WHEN 'CASHOUTHOMEIMPROVEMENT'           THEN '2' -- Cash Out
                                     WHEN 'CASHOUTLIMITED'                   THEN '2' -- Cash Out
                                     WHEN 'CASHOUTOTHER'                     THEN '2' -- Cash Out
                                     WHEN 'CHANGEINRATETERM'                 THEN '1' -- Not Streamlined, Not Cash Out
                                     WHEN 'NA'                               THEN '1' -- Not Streamlined, Not Cash Out
                                     WHEN 'NOCASHOUTFHASTREAMLINEDREFINANCE' THEN '3' -- Streamlined
                                     WHEN 'NOCASHOUTSTREAMLINEDREFINANCE'    THEN '3' -- Streamlined
                                     WHEN 'VASTREAMLINEDREFINANCE'           THEN '3' -- Streamlined
                                     ELSE NULL
                                   END
             ELSE NULL
           END                               AS refinance_type,
           CLD.IntPaidThruDt                 AS last_paid_installment_due_date,
           NULL                              AS pre_mod_first_installment_due_date,
           NULL                              AS pre_mod_original_principal_balance,
           NULL                              AS pre_mod_interest_rate,
           NULL                              AS pre_mod_maturity_date,
           CASE LEFT(CLD.LnNbr, 1)
             WHEN '1' THEN '3' -- Retail
             WHEN '6' THEN '1' -- Broker (Wholesale)
             WHEN '8' THEN '2' -- Correspondent (Reimbursement)
             WHEN '4' THEN '3' -- Retail (Consumer Direct)
             ELSE NULL
           END                               AS third_party_origination_type,
           CLD.FHAUpfrontMIP                 AS upfront_mortgage_insurance_premium_rate,
           CLD.FHAMIRenewalRate              AS annual_mortgage_insurance_premium_rate,
           CASE WHEN CONVERT(varchar, CLD.NoteDt, 101) <> '01/01/1900' THEN CLD.NoteDt
             ELSE NULL END AS loan_origination_date
    FROM CTM.smds.SMDSCompassLoanDetails CLD
    WHERE CLD.InvestorCommitNbr LIKE 'GE%'
  eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  # format A|B[|C]
  # A is type F=filler(space), X=Alphanumeric, D=Date(YYYYMMDD), 9=Numeric
  # B is length
  # C is optional and is the number of decimal places for floats (no C means it's an integer)
  FILE_SPEC = {
    'M01' => {
      :filler_1                  => 'F|1',
      :ginnie_pool_number        => 'X|6',
      :issue_type                => 'X|1',
      :pool_type                 => 'X|2',
      :loan_number               => 'X|15',
      :case_number               => 'X|15',
      :mortgage_type             => 'X|1',
      :filler_2                  => 'F|1',
      :interest_rate             => '9|2|3',
      :principal_and_interest    => '9|5|2',
      :original_principal_amount => '9|7|2',
      :unpaid_principal_balance  => '9|7|2',
      :filler_3                  => 'F|1'
      },
    'M02' => {
      :first_pay_date                    => 'D|8',
      :last_pay_date                     => 'D|8',
      :unscheduled_principal_curtailment => '9|6|2',
      :percent_of_increase               => '9|2|3',
      :mortgage_margin                   => '9|2|3',
      :manufactured_home_type            => 'X|2',
      :filler_1                          => 'F|1',
      :mers_original_mortgagee           => 'X|1',
      :mers_identification_number        => 'X|18',
      :filler_2                          => 'F|18'
      },
    'M03' => {
      :mortgage_address  => 'X|40',
      :mortgage_city     => 'X|21',
      :mortgage_state    => 'X|2',
      :mortgage_zip      => 'X|9',
      :filler_1          => 'X|5'
      },
    'M04' => {
      :borrower_first_name    => 'X|25',
      :borrower_last_name     => 'X|25',
      :borrower_ssn           => 'X|9',
      :ltv                    => '9|3|2',
      :loan_application_date  => 'D|8',
      :first_time_homebuyer   => 'X|1',
      :filler_1               => 'F|3'
      },
    'M05' => {
      :coborrower1_first_name  => 'X|25',
      :coborrower1_last_name   => 'X|25',
      :coborrower1_ssn         => 'X|9',
      :filler_1                => 'F|18'
      },
    'M06' => {
      :coborrower2_first_name  => 'X|25',
      :coborrower2_last_name   => 'X|25',
      :coborrower2_ssn         => 'X|9',
      :filler_1                => 'F|18'
      },
    'M07' => {
      :coborrower3_first_name  => 'X|25',
      :coborrower3_last_name   => 'X|25',
      :coborrower3_ssn         => 'X|9',
      :filler_1                => 'F|18'
      },
    'M10' => {
      :loan_key                            => '9|9',
      :loan_type_code                      => 'X|1',
      :filler_1                            => 'F|3',
      :loan_purpose                        => 'X|1',
      :living_units                        => '9|1',
      :filler_2                            => 'F|1',
      :down_payment_assistance             => 'X|1',
      :loan_level_credit_score             => '9|3',
      :loan_buydown_code                   => 'X|1',
      :upfront_mortgage_insurance_premium  => '9|5|2',
      :annual_mortgage_insurance_premium   => '9|5|2',
      :filler_3                            => 'F|3',
      :interest_rate_change_date           => 'D|8',
      :index_type                          => 'X|5',
      :acceptable_range                    => 'X|7',
      :arm_type                            => 'F|14',
      :initial_cap                         => 'X|1',
      :subsequent_cap                      => 'X|1',
      :lifetime_cap                        => 'X|1'
    },
    'M11' => {
      :cltv                                    => '9|3|2',
      :dti                                     => '9|3|2',
      :refinance_type                          => 'X|1',
      :last_paid_installment_due_date          => 'D|8',
      :pre_mod_first_installment_due_date      => 'D|8',
      :pre_mod_original_principal_balance      => '9|8|2',
      :pre_mod_interest_rate                   => '9|2|3',
      :pre_mod_maturity_date                   => 'D|8',
      :third_party_origination_type            => 'X|1',
      :upfront_mortgage_insurance_premium_rate => '9|2|3',
      :annual_mortgage_insurance_premium_rate  => '9|2|3',
      :loan_origination_date                   => 'D|8',
      :filler_1                                => 'F|2'
    }
  }

  def ginnie_pool_number
    gnma_pool.ginnie_pool_number
  end

  def issue_type
    gnma_pool.issue_type
  end

  def pool_type
    gnma_pool.pool_type
  end

  # This is required because the UlddBorrower fetches borrower information through loan.master_borrower(index)
  def master_borrower(index)
    master_borrowers.by_position(index)
  end

  def borrowers  
    master_borrowers.map {|mb| Smds::UlddBorrower.new(self, mb.get_index)}
  end

  def loan_level_credit_score
    representative_fico
    # borrowers.map { |b| b.credit_score.to_i }.reject(&:zero?).min
  end

end

unless defined?(GnmaLoan)
  GnmaLoan = Smds::GnmaLoan #Rails can't make up it's mind about which one it is looking for.
end
