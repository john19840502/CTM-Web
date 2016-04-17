class Residence < DatabaseDatamartReadonly

  belongs_to :loan_general
 
  CREATE_VIEW_SQL = <<-eos
    SELECT  _RESIDENCE_id                 as id,
		BorrowerResidencyBasisType    as borrower_residency_basis_type
    FROM    LENDER_LOAN_SERVICE.dbo._RESIDENCE
   eos
 
  end
