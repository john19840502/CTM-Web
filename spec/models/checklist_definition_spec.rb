require 'spec_helper'

describe ChecklistDefinition do

  let(:definition) { ChecklistDefinition.new double }

  it "should return default sections" do
    expect(definition.sections).to eq []
  end

  it "should return default questions" do
    expect(definition.questions).to eq []
  end

end
