class AddInitialValuesForStateTitleVendors < ActiveRecord::Migration

  def up
    republic = Vendor.create(:name => "Old Republic")
    fidelity = Vendor.create(:name => "Fidelity")
    american = Vendor.create(:name => "First American")

    create_preferred_vendor "AL", republic, republic
    create_preferred_vendor "AZ", fidelity, fidelity
    create_preferred_vendor "AR", fidelity, fidelity
    create_preferred_vendor "CA", fidelity, fidelity
    create_preferred_vendor "CO", fidelity, fidelity
    create_preferred_vendor "CT", fidelity, fidelity
    create_preferred_vendor "DE", republic, republic
    create_preferred_vendor "DC", american, american
    create_preferred_vendor "FL", american, american
    create_preferred_vendor "GA", republic, republic
    create_preferred_vendor "HI", american, american
    create_preferred_vendor "ID", fidelity, fidelity
    create_preferred_vendor "IL", fidelity, fidelity
    create_preferred_vendor "IN", fidelity, fidelity
    create_preferred_vendor "IA", fidelity, fidelity
    create_preferred_vendor "KS", fidelity, fidelity
    create_preferred_vendor "KY", fidelity, fidelity
    create_preferred_vendor "LA", fidelity, fidelity
    create_preferred_vendor "ME", fidelity, fidelity
    create_preferred_vendor "MD", fidelity, fidelity
    create_preferred_vendor "MA", fidelity, fidelity
    create_preferred_vendor "MI", fidelity, fidelity
    create_preferred_vendor "MS", fidelity, fidelity
    create_preferred_vendor "MN", fidelity, fidelity
    create_preferred_vendor "MO", fidelity, fidelity
    create_preferred_vendor "NE", fidelity, fidelity
    create_preferred_vendor "NV", fidelity, fidelity
    create_preferred_vendor "NH", republic, republic
    create_preferred_vendor "NJ", fidelity, fidelity
    create_preferred_vendor "NM", american, american
    create_preferred_vendor "NY", fidelity, fidelity
    create_preferred_vendor "NC", republic, republic
    create_preferred_vendor "ND", republic, republic
    create_preferred_vendor "OH", republic, republic
    create_preferred_vendor "OK", american, american
    create_preferred_vendor "OR", american, american
    create_preferred_vendor "PA", republic, republic
    create_preferred_vendor "RI", fidelity, fidelity
    create_preferred_vendor "SC", republic, republic
    create_preferred_vendor "SD", fidelity, fidelity
    create_preferred_vendor "TN", fidelity, fidelity
    create_preferred_vendor "TX", fidelity, fidelity
    create_preferred_vendor "UT", american, american
    create_preferred_vendor "VT", republic, republic
    create_preferred_vendor "VA", fidelity, fidelity
    create_preferred_vendor "WA", fidelity, fidelity
    create_preferred_vendor "WI", fidelity, fidelity
  end

  def down
    StateTitleVendor.delete_all
    Vendor.delete_all
  end

  private

  def create_preferred_vendor state, retail_vendor, wholesale_vendor
    s = StateTitleVendor.new
    s.state = state
    s.retail_vendor_id = retail_vendor.id
    s.wholesale_vendor_id = wholesale_vendor.id
    s.save
  end

end
