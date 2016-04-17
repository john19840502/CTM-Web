module Underwriter::ChecklistsHelper
  def bullet(type)
    
    case type
    when 'yes_or_no'
      'oh hi'
    else
      nil
    end
  end
  
  def escrow_waiver_field(loan)
    "LOAN: #{truth_as_yes_no loan.is_escrow_waived}
     <br/>
     LOCK: #{truth_as_yes_no loan.locked_loan_snapshot.is_escrow_waived rescue nil}"
  end
  
  def borrower_last_name_field(loan)
    h loan.borrowers.first.last_name rescue '[ERROR]'
  end
  
  def borrower_first_name_field(loan)
    h loan.borrowers.first.first_name rescue '[ERROR]'
  end
end
