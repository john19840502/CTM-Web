require 'avista_date'

module Smds
  class CompassLoanDetail < ::DatabaseDatamart
    self.table_name_prefix += 'smds_'

    def self.primary_key
      'loan_number'
    end

    validates :final_note_rate,         presence: true, numericality: true
    validates :loan_amount,             presence: true, numericality: true
    validates :principal_and_interest,  presence: true, numericality: true
    validates :upb,                     presence: true, numericality: true
    validates :loan_number,             presence: true

    belongs_to :pool, :class_name => 'Smds::Pool', foreign_key: :investor_commitment_number, primary_key: :investor_commitment_number

    CREATE_VIEW_SQL = <<-eos
        SELECT
               CalcUPB           AS calc_upb,
               CalcSoldScheduledBal AS calc_sold_scheduled_balance,
               CalcAggregateLoanCurtailments AS calc_aggregate_loan_curtailments,
               FinalNoteRate     AS final_note_rate,
               FirstPmtDt        AS first_payment_date,
               GLPurByInvDt      AS gl_purchase_by_investor_date,
               HUDCurtailment    AS hud_curtailment,
               IntPaidThruDt     AS interest_paid_through_date,
               InvestorCommitNbr AS investor_commitment_number,
               InvestorName      AS investor_name,
               LnAmt             AS loan_amount,
               LnNbr             AS loan_number,
               LnRemainingTerm   AS loan_remaining_term,
               MaturityDt        AS maturity_date,
               NextPmtDt         AS next_payment_date,
               PaidOffFlag       AS paid_off_flag,
               PI                AS principal_and_interest,
               Servicer          AS servicer,
               ServicerLnNbr     AS servicer_loan_number,
               InvestorRclExpDt  AS settlement_date,
               UPB               AS upb,
               LnAmortType       AS LnAmortType,
               Assumable         AS Assumable,
               Brw1Race1         AS Brw1Race1,
               Brw1Race2         AS Brw1Race2,
               Brw1Race3         AS Brw1Race3,
               Brw1Race4         AS Brw1Race4,
               Brw1Race5         AS Brw1Race5,
               Brw2Race1         AS Brw2Race1,
               Brw2Race2         AS Brw2Race2,
               Brw2Race3         AS Brw2Race3,
               Brw2Race4         AS Brw2Race4,
               Brw2Race5         AS Brw2Race5,
               Brw3Race1         AS Brw3Race1,
               Brw3Race2         AS Brw3Race2,
               Brw3Race3         AS Brw3Race3,
               Brw3Race4         AS Brw3Race4,
               Brw3Race5         AS Brw3Race5,
               Brw4Race1         AS Brw4Race1,
               Brw4Race2         AS Brw4Race2,
               Brw4Race3         AS Brw4Race3,
               Brw4Race4         AS Brw4Race4,
               Brw4Race5         AS Brw4Race5,
               Brw1Age           AS Brw1Age,
               Brw2Age           AS Brw2Age,
               Brw3Age           AS Brw3Age,
               Brw4Age           AS Brw4Age,
               Brw1Gender        AS Brw1Gender,
               Brw2Gender        AS Brw2Gender,
               Brw3Gender        AS Brw3Gender,
               Brw4Gender        AS Brw4Gender

        FROM CTM.smds.SMDSCompassLoanDetails
    eos

    def self.sqlserver_create_view
      CREATE_VIEW_SQL
    end

    coerce_sqlserver_date :first_payment_date, :next_payment_date, :maturity_date, :settlement_date

    def self.create_pools
      investor_numbers = self.pluck(:investor_commitment_number).compact.uniq.keep_if{|number| number.starts_with?('ME')}
      pool_numbers = Smds::Pool.fnma.pluck(:investor_commitment_number)
      pools_to_create = investor_numbers - pool_numbers
      pools_to_create.each do |pool|
        detail = self.find_by_investor_commitment_number(pool)
        Smds::Pool.create!({:investor_commitment_number => pool,
                           prefix: 'ME',
                           settlement_date: detail.settlement_date,
                           pool_issue_date: detail.pool_issue_date},
                         without_protection: true)
      end
    end

    def AssumabilityIndicator
      return false if self.LnAmortType.eql?('Fixed')
      return true if self.LnAmortType.eql?('AdjustableRate') || self.Assumable == "Y"
      false
    end 

    def race_entries index
      races = []
      (1..5).each do |ix|
        races.push self["Brw#{index+1}Race#{ix}"]
      end
      races.reject(&:blank?).compact
    end

    def gender_type index
      self["Brw#{index+1}Gender"]
    end

    def self.cash_numbers
      self.pluck(:investor_commitment_number).compact.uniq.keep_if{|number| number.starts_with?('FN')}
    end

    def pool_issue_date
      ::CTM::AvistaDate.new(settlement_date.beginning_of_month)
    end

    def settlement_date
      ::CTM::AvistaDate.new(super)
    end

    def first_payment_date
      ::CTM::AvistaDate.new(super)
    end

    def maturity_date
      ::CTM::AvistaDate.new(super)
    end

    def interest_paid_through_date
      ::CTM::AvistaDate.new(super)
    end

    def fnma_loan
      commit_number = self.investor_commitment_number
      if commit_number.starts_with?('FN')
        pool_loans = Smds::FnmaLoan.where('InvestorCommitmentIdentifier' => commit_number[2..-1])
      elsif commit_number.starts_with?('ME')
        pool_loans = Smds::FnmaLoan.where('InvestorContractIdentifier' => commit_number[2..-1])
      end
      pool_loans.where('SellerLoanIdentifier' => self.loan_number).first
    end

    def fhlmc_loan
      Smds::FhlmcLoan.find(self.loan_number)
    end
  end
end
