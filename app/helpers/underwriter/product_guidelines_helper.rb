module Underwriter::ProductGuidelinesHelper
  def current_guideline_column(record, column)
    html = ''
    Channel.all.map(&:identifier).each do |ch|
      unless (cg = record.current_guideline(ch)).nil?
        html << "#{ch} :: <a target='_blank' href='#{cg.document}'>#{cg.document_file_name}</a>&nbsp;&nbsp;Effective Date: #{cg.effective_date.strftime('%m/%d/%Y')}<br />"
      end
    end
    html << "No current guideline document found" if html.blank?
    raw html
  end
end
