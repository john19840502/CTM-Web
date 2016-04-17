module Bpm::StatisticReportsHelper

  def count_loans(validation_requests)
    validation_requests.map(&:loan_status).map(&:loan_num).uniq.count
  end

  def count_errors(validation_requests)
    validation_requests.inject(0) do |sum,vr|
      sum += vr.validation_messages.select {|msg| msg.type == 'error'}.count
    end
  end

  def count_warnings(validation_requests)
    validation_requests.inject(0) do |sum,vr|
      sum += vr.validation_messages.select {|msg| msg.type == 'warning'}.count
    end
  end
end
