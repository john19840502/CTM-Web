# == Schema Information
#
# Table name: ctmweb_product_data_development
#
#  id                            :integer          not null, primary key
#  loan_type                     :string(255)
#  program                       :string(255)
#  price_code                    :string(255)
#  amortization_type             :string(255)
#  amortization_term             :string(255)
#  product_code                  :string(255)
#  bfn_gfe_mortgage_product_type :string(255)
#  bfn_loan_product_name         :string(255)
#  product_name                  :string(255)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#

class ProductDatum < ActiveRecord::Base
  attr_accessible :amortization_term, :amortization_type, :bfn_gfe_mortgage_product_type, 
                  :bfn_loan_product_name, :loan_type, :price_code, :product_code, :product_name, :program

  validates :product_code, presence: true
  
  def to_label
    "Product #{product_code}"
  end                  
end
