class TransactionDetail < DatabaseDatamartReadonly
  belongs_to :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT
        TRANSACTION_DETAIL_id                     AS id,
        loanGeneral_Id                            AS loan_general_id,
        AlterationsImprovementsAndRepairsAmount   AS alterations_improvements_and_repairs_amount,
        BorrowerPaidDiscountPointsTotalAmount     AS borrower_paid_discount_points_total_amount,
        EstimatedClosingCostsAmount               AS estimated_closing_costs_amount,
        MIAndFundingFeeFinancedAmount             AS mi_and_funding_fee_financed_amount,
        MIAndFundingFeeTotalAmount                AS mi_and_funding_fee_total_amount,
        PrepaidItemsEstimatedAmount               AS prepaid_items_estimated_amount,
        PurchasePriceAmount                       AS purchase_price_amount,
        RefinanceIncludingDebtsToBePaidOffAmount  AS refinance_including_debts_to_be_paid_off_amount,
        SalesConcessionAmount                     AS sales_concession_amount,
        SellerPaidClosingCostsAmount              AS seller_paid_closing_costs_amount,
        SubordinateLienAmount                     AS subordinate_lien_amount,
        SubordinateLienHELOCAmount                AS subordinate_lien_heloc_amount,
        LandAmount                                AS land_amount,
        FREReservesAmount                         AS fre_reserves_amount,
        UndrawnHelocAmount                        AS undrawn_heloc_amount,
        Concession                                AS consession

      FROM       LENDER_LOAN_SERVICE.dbo.[TRANSACTION_DETAIL]
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  #### ULDD
  def subordinate?
    subordinate_lien_amount.to_i > 0
  end

  def current_heloc_maximum_balance_amount
    return 0 unless undrawn_heloc_amount.to_i > 0
    subordinate_lien_amount.to_i + undrawn_heloc_amount
  end

  def heloc?
    undrawn_heloc_amount.to_i > 0
  end

  def secondary_mortgage?
    subordinate? && !heloc?
  end

  def lien_position
    'SecondLien'
  end

  def unpaid_balance_amount
    subordinate_lien_amount.to_i
  end

  #### ULDD END

  # add lines A thru H on Details of transaction
  def line_i
    purchase_price_amount.to_f +
    alterations_improvements_and_repairs_amount.to_f +
    land_amount.to_f +
    refinance_including_debts_to_be_paid_off_amount.to_f +
    prepaid_items_estimated_amount.to_f +
    estimated_closing_costs_amount.to_f +
    mi_and_funding_fee_total_amount.to_f +
    borrower_paid_discount_points_total_amount.to_f
  end

  def net_loan_disbursement_amount
    ((loan_general.nil? or loan_general.mortgage_term.nil?) ? 0 : loan_general.mortgage_term.base_loan_amount.to_f) +
    mi_and_funding_fee_financed_amount.to_f
  end

  # Calculates as follows: lines I - J - K - L - O on Details of transaction
  def total_funds_required_to_close
    line_i -
    subordinate_lien_amount.to_f -
    seller_paid_closing_costs_amount.to_f -
    ((loan_general.nil? or loan_general.purchase_credit_amount.nil?) ? 0 : loan_general.purchase_credit_amount) -
    net_loan_disbursement_amount
  end
end
