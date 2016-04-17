class CtmLoan < DatabaseDatamart
  attr_accessible :uw_coord_submission

  belongs_to :coordinator, class_name: 'CtmUser', foreign_key: :uw_coord_submission

  alias_attribute :coordinator_pid, :uw_coord_submission
  alias_attribute :coordinator_id, :uw_coord_submission

  def self.sqlserver_create_view
    <<-eos
      SELECT
          Loan_Num AS loan_id,
          UW_Submit_date AS uw_submitted_at,
          UW_Coord_Submission AS uw_coord_submission,
          UW_Coord_Conditions AS uw_coord_conditions,
          UW_Initial_Decision AS uw_initial_decision,
          UW_Initial_Decision_Date AS uw_initial_decision_date
      FROM       LENDER_LOAN_SERVICE.dbo.[ctm_Loan]
    eos
  end

  def update_coordinator(coordinator)
    self.uw_coord_submission = coordinator.id
    self.save
  end
end
