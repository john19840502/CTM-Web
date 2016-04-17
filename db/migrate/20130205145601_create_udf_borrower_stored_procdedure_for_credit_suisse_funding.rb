class CreateUdfBorrowerStoredProcdedureForCreditSuisseFunding < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        CREATE FUNCTION [ctm].[udf_borrower_get_number_of_borrowers]
        (
          -- Add the parameters for the function here
          @loan_general_id int
        )
        RETURNS tinyint
        AS
        BEGIN
          -- Declare the return variable here
          DECLARE @result tinyint

          SET @result = 0
          
          -- Add the T-SQL statements to compute the return value here
          SELECT @result = COUNT(*)
          FROM LENDER_LOAN_SERVICE.dbo.BORROWER
          WHERE loanGeneral_Id = @loan_general_id
          GROUP BY loanGeneral_Id

          -- Return the result of the function
          RETURN @result

        END
      SQL
    end
  end

  def down
  end
end
