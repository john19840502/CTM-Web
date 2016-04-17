require 'spec_helper'

describe Bpm::StatisticReportsController do

  let(:user) { fake_rubycas_login }

  before do
    user
  end

  describe "index" do

    it "should assign some things" do
      get :index
      assigns(:bpm_statistic_report).should be_a_new BpmStatisticReport
      assigns(:bpm_prior_searches).should_not be_nil
    end

    it "should get the most recent 5 searches created by this user" do
      a = BpmStatisticReport.create!({user_uuid: 'foo'}, without_protection: true)
      stuff = (1..5).map do |n|
        BpmStatisticReport.create!({user_uuid: user.uuid}, without_protection: true)
      end
      Time.stub now: Time.new(2010, 1, 1)
      old = BpmStatisticReport.create!({user_uuid: user.uuid}, without_protection: true)

      get :index
      assigns(:bpm_prior_searches).map(&:id).should match_array stuff.map(&:id)
    end
  end

end
