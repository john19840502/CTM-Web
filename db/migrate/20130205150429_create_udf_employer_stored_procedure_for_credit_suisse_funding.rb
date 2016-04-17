class CreateUdfEmployerStoredProcedureForCreditSuisseFunding < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        CREATE FUNCTION [ctm].[udf_employer_get_years_employed]
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
          SELECT TOP 1 @result = CONVERT(decimal(4,2), ISNULL(CurrentEmploymentYearsOnJob, 0) + CONVERT(decimal(4,2), ISNULL(CurrentEmploymentMonthsOnJob, 0)) / 12)
          FROM LENDER_LOAN_SERVICE.dbo.EMPLOYER
          WHERE loanGeneral_Id = @loan_general_id
            AND UPPER(RTRIM(BorrowerID)) = UPPER(RTRIM(@borrower_id))
            AND EmploymentCurrentIndicator = 1
            AND EmploymentPrimaryIndicator = 1
          ORDER BY CurrentEmploymentYearsOnJob DESC, CurrentEmploymentMonthsOnJob DESC

          -- Return the result of the function
          RETURN @result

        END
      SQL
    end
  end

  def down
  end
end
