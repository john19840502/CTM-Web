require 'spec_helper'

describe FundingChecklist do
  before { FundingChecklist.delete_all }
  let(:funding_chk) { FundingChecklist.new }
  describe ".completion_date" do
    it "should return '' date if checklist is not completed" do
      expect(funding_chk.completion_date).to eq ''
    end

    it "should return the completed date when the checklist is completed" do
      funding_chk.stub completed: true
      funding_chk.save
      expect(funding_chk.completion_date).to eq Date.today
    end
  end

  describe ".elapsed_time" do
    before { funding_chk.stub completed: true }
    it "should return '' if the checklist is not completed" do
      funding_chk.stub completed: false
      expect(funding_chk.elapsed_time).to eq ''
    end

    it "should return '0 day' when the checklist is completed on same day" do
      funding_chk.save
      expect(funding_chk.elapsed_time).to eq "0 day"
    end

    it "should return 2 days" do
      funding_chk.stub created_at: Time.zone.parse("2015-11-23")
      funding_chk.stub updated_at: Time.zone.parse("2015-11-25")

      expect(funding_chk.elapsed_time).to eq "2 days"
    end

    it "should return elapsed time by excluding holidays" do
      funding_chk.stub created_at: Time.zone.parse("2015-11-23")
      funding_chk.stub updated_at: Time.zone.parse("2015-11-30")

      expect(funding_chk.elapsed_time).to eq "4 days"
    end
  end
end
