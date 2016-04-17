module Underwriter::ProductGuidelineDocsHelper
  def document_file_size_column(record, column)
    "#{record.document_file_size / 1000} Kb" if record.document_file_size
  end
  
  def channel_form_column(record, options)
    select :record, :channel, Channel.all.collect {|ch| [ ch.identifier, ch.identifier ] }
  end
end
