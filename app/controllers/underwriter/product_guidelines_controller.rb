class Underwriter::ProductGuidelinesController < RestrictedAccessController
  load_and_authorize_resource
  
  active_scaffold :product_guideline do |config|

    list.sorting = {product_code: 'ASC'}
    config.label = 'Product Guidelines'
    config.create.label = 'Add Product Code'
    
    config.create.columns = [:product_code]
    config.update.columns = [:product_code]

    config.columns = [:product_code,
                      :current_guideline]

    config.columns[:product_code].label = 'Product Code'
    config.columns[:current_guideline].label = 'Current Guideline Document'

    config.create.link.label = 'Add New Product Code'
    config.nested.add_link :product_guideline_docs, label: 'File History'

    config.actions.exclude :show
    config.actions.exclude :update
  end
end