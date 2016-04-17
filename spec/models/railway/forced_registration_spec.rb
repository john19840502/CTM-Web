require 'spec_helper'

describe ForcedRegistration do
  it "sets visibility to false when action is 'consent withdrawn'" do
    ForcedRegistration.create({
      :visible => true,
      :user_action => 'New Entry',
    })

    fr = ForcedRegistration.last
    expect(fr.visible).to eq(true)
    update_hash = {:user_action => 'consent withdrawn', :comment => 'foobar comment'}
    fr.update_attributes(update_hash)
    expect(fr.visible).to eq(false)
  end

  it "does not set visibility to false when action is other than 'consent withdrawn'" do
    ForcedRegistration.create({
      :visible => true,
      :user_action => 'New Entry',
    })

    fr = ForcedRegistration.last
    expect(fr.visible).to eq(true)
    update_hash = {:user_action => 'Contacted LO'}
    fr.update_attributes(update_hash)
    expect(fr.visible).to eq(true)

  end
end
