module Underwriter::FileReceivedNoUwAssignedHelper
  def is_jumbo_candidate_column(record)
    record.is_jumbo_candidate? ? 'Yes' : 'No'
  end
end
