require 'spec_helper'

describe Note do
  describe 'instance methods' do
    it 'should return a proper name' do
      note = FactoryGirl.build_stubbed(:note, entry_method: 'Test', created_at: Time.now.utc)
      note.name.should eq("#{note.created_at.to_s(:short)} - #{note.entry_method}")
    end
  end
end
