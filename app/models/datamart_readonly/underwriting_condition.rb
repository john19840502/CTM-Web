class UnderwritingCondition < DatabaseDatamartReadonly
  belongs_to :loan_general


  def self.sqlserver_create_view
    <<-eos
      SELECT  UNDERWRITING_CONDITIONS_id  AS id,
                loanGeneral_Id            AS loan_general_id,
                _Status                   AS status,
                _Condition                AS condition,
                _ClearedDate              AS cleared_date,
                _ConditionDate            AS condition_date
      FROM    LENDER_LOAN_SERVICE.dbo.[UNDERWRITING_CONDITIONS]
    eos
  end

end


# CREATE TABLE [dbo].[UNDERWRITING_CONDITIONS] (
#   [UNDERWRITING_CONDITIONS_id] int IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
#   [loanGeneral_Id] int NULL,
#   [_Status] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
#   [_Type] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
#   [_Condition] varchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
#   [_ReceivedDate] smalldatetime NULL,
#   [_ClearedDate] smalldatetime NULL,
#   [_ClearedByUsername] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
#   [_ConditionDate]
