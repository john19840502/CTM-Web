require 'spec_helper'
describe Noteable do
  it 'should call Note.create' do
    #Note.stub!(:new)
    note = build_stubbed(:note)
    note.stub(:current_user) { build_stubbed_user }
    note.extend(Noteable)
    
    note.write_note('hello').should be true
  end
end
