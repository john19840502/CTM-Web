class Underwriter::ProductGuidelineDocsController < RestrictedAccessController
  active_scaffold :product_guideline_doc do |config|

    config.columns = [:effective_date,  
                      :channel,
                      :document]

    config.list.columns = [:effective_date,
                      :channel,
                      :document,
                      :document_file_size,
                      :document_updated_at]

    config.create.multipart = true
    config.update.multipart = true

    config.create.link.label = 'Add New Document'
    config.list.sorting = { :effective_date => :desc }

    config.list.label = 'Guideline Documents'
    config.create.label = 'Add Guideline Document'

    config.actions.exclude :search
    config.actions.exclude :show
  end
end