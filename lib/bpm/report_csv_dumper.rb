
module Bpm
  class ReportCsvDumper
    def dump query_result
      CSV.generate do |csv|
        csv << headers
        query_result.validation_requests.each do |request|
          messages = request.validation_messages.to_a
          messages << nil if messages.empty?
          messages.each do |msg|
            csv << get_values(request, msg)
          end
        end
      end
    end

    def headers
      h = strip_mongo_junk Mdb::ValidationRequest.fields.keys - ["initial_decision", "final_approval"]
      h += strip_mongo_junk Mdb::LoanStatus.fields.keys
      h += strip_mongo_junk Mdb::ValidationMessage.fields.keys - ["is_reviewed", "reviewed_by", "reviewed_at"]
      h.delete('fact_types')
      h
    end

    def strip_mongo_junk(column_names)
      column_names - [ '_id', '_type' ]
    end

    def get_values(request, msg)
      [
        request.validated_by,
        request.validated_by_id,
        format_date(request.date),
        request.total_rules_applied,
        request.validation_type,
        request.loan_status.loan_num,
        request.loan_status.underwriter,
        request.loan_status.product_code,
        request.loan_status.channel,
        request.loan_status.state,
        request.loan_status.status,
        request.loan_status.pipeline_status,
        message_type(msg),
        message_text(msg),
      ]
    end


    def format_date(date)
      return '' if date.nil?
      I18n.l date, format: :mers
    end

    def message_type(msg)
      return 'No errors or warnings' unless msg
      msg.type
    end

    def message_text(msg)
      return '' unless msg
      msg.message
    end
  end
end
