class Underwriter::ProductDataController < RestrictedAccessController
  load_and_authorize_resource
  
  active_scaffold :product_datum do |config|

    list.sorting = {product_code: 'ASC'}
    config.label = 'Product Data'
    config.create.label = 'Add Product'
    
    config.list.columns =   [:product_code,
                             :product_name,
                             :loan_type, 
                             :price_code]

    config.columns[:product_code].label                     = 'Product Code'                    
    config.columns[:amortization_term].label                = 'Amortization Term'
    config.columns[:amortization_type].label                = 'Amortization Type'
    config.columns[:bfn_gfe_mortgage_product_type].label    = 'BFN GFE Mortgage Product Type'
    config.columns[:bfn_loan_product_name].label            = 'BFN Loan Product Name'
    config.columns[:loan_type].label                        = 'Loan Type'
    config.columns[:price_code].label                       = 'Price Code'
    config.columns[:product_name].label                     = 'Product Name'
    config.columns[:program].label                          = 'Program'
    
    config.actions.exclude :delete
  end
end