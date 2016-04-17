require 'spec_helper'

describe Underwriter::ProductGuidelinesController do
  render_views

  before do
    fake_rubycas_login
  end

  it "get :index" do
    ProductGuideline.create!({product_code: 'abc'}, without_protection: true)
    get :index
  end

end
