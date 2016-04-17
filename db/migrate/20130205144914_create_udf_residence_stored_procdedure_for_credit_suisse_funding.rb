class CreateUdfResidenceStoredProcdedureForCreditSuisseFunding < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        CREATE FUNCTION [ctm].[udf_residence_get_years_in_home]
        (
          -- Add the parameters for the function here
          @loan_general_id int,
          @borrower_id varchar(50)
        )
        RETURNS decimal(4,2)
        AS
        BEGIN
          -- Declare the return variable here
          DECLARE @result decimal(4,2)

          SET @result = 0
          
          -- Add the T-SQL statements to compute the return value here
          SELECT TOP 1 @result = CONVERT(decimal(4,2), ISNULL(BorrowerResidencyDurationYears, 0) + CONVERT(decimal(4,2), ISNULL(BorrowerResidencyDurationMonths, 0)) / 12)
          FROM LENDER_LOAN_SERVICE.dbo._RESIDENCE
          WHERE loanGeneral_Id = @loan_general_id
            AND UPPER(RTRIM(BorrowerID)) = UPPER(RTRIM(@borrower_id))
            AND UPPER(RTRIM(BorrowerResidencyType)) = 'CURRENT'
          ORDER BY BorrowerResidencyDurationYears DESC, BorrowerResidencyDurationMonths DESC

          -- Return the result of the function
          RETURN @result

        END
      SQL
    end
  end

  def down
  end
end
