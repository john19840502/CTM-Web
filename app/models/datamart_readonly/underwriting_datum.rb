class UnderwritingDatum < DatabaseDatamartReadonly
  belongs_to :loan_general
  has_one :cond_pending_review, through: :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT
        UNDERWRITING_DATA_id            AS id,
        loanGeneral_Id                  AS loan_general_id,
        _ApprovalRate                   AS approval_rate,
        _ConditionalApprovalDate        AS conditional_approval_at,
        _ConditionsPendingReviewDate    AS conditions_pending_review_at,
        _DeniedDate                     AS denied_at,
        _DueOutDate                     AS due_out_at,
        _FinalApprovalDate              AS final_approval_at,
        _FinalApprovalReadyForDocsDate  AS final_approval_ready_for_docs_at,
        _FinalApprovalReadyForFundDate  AS final_approval_ready_for_fund_at,
        _ModifyWithConditionsDate       AS modify_with_conditions_at,
        _PendingSecondReviewDate        AS pending_second_review_at,
        _PreApprovalDate                AS pre_approval_at,
        _ReadyForDocsDate               AS ready_for_docs_at,
        _ReceivedDate                   AS received_at,
        _ReSubmittedDate                AS resubmitted_at,
        _Status                         AS status,
        _SubmittedDate                  AS submitted_at,
        _SuspendedDate                  AS suspended_at,
        _Template                       AS template,
        AppraisalDate                   AS appraisal_at,
        AppraisalExpireDate             AS appraisal_expire_at,
        AppraisalNeededByDate           AS appraisal_need_by,
        AppraisalOrderedDate            AS appraisal_ordered_at,
        BorrowerCreditScore             AS borrower_credit_score,
        BorrowerVerifiedAssetsAmount    AS borrower_verified_assets_amount,
        CoBorrowerCreditScore           AS co_borrower_credit_score,
        CreditDocsExpireDate            AS credit_docs_expire_at,
        MaximumRate                     AS maximum_rate,
        ProductCode                     AS product_code,
        ProductDescription              AS product_description,
        PublishUnderwritingDecision     AS publish_underwriting_decision,
        RedisclosureDate                AS redisclosure_at,
        RepresentativeCreditScore       AS representative_credit_score,
        AppraisalSentToBorrower         AS appraisal_sent_to_borrower,
        SecondAppraisalSentToBorrower   AS second_appraisal_sent_to_borrower,
        AppraisalDeliveryMethod         AS appraisal_delivery_method,
        SecondAppraisalDeliveryMethod   AS second_appraisal_delivery_method,
        ConsentToWaiveDeliveryReceived  AS consent_to_waive_delivery_received,
        UnderwriterName                 AS underwriter_name

      FROM       LENDER_LOAN_SERVICE.dbo.[UNDERWRITING_DATA]
    eos
  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end
