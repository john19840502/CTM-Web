require 'spec_helper'

RSpec.describe ValidationAlertsController, :type => :controller do
  before do
    fake_rubycas_login
  end

  describe "clear" do
    let(:params) { { loan_id: 123, rule_id: 89, text: "hi", alert_type: 'preclosing', reason: 'nothing'} }

    it "should make a new alert from the params" do
      expect {
        post :clear, params
      }.to change {ValidationAlert.count}.by(1)
    end

    it "should render the validation alert as json" do
      post :clear, params
      expect(response.status).to eq 200
      expect(JSON.parse response.body).to include "alert_type" => "preclosing", "loan_id" => "123", "rule_id" => 89, "reason" => "nothing", "action" => "Cleared"
    end

    it "should report something useful if the Alert can't be saved" do
      ValidationAlert.stub(:create!).and_raise("something went wrong")
      post :clear, params
      expect(response.status).to eq 500
      expect(JSON.parse response.body).to include "message" => "something went wrong"
    end
  end

  describe "reinstate" do
    let(:params) { { loan_id: 123, rule_id: 89, text: "hi", alert_type: 'preclosing', reason: 'nothing'} }

    it "should make a new alert from the params" do
      expect {
        post :reinstate, params
      }.to change {ValidationAlert.count}.by(1)
    end

    it "should render the validation alert as json" do
      post :reinstate, params
      expect(response.status).to eq 200
      expect(JSON.parse response.body).to include "alert_type" => "preclosing", "loan_id" => "123", "rule_id" => 89, "reason" => "nothing", "action" => "Reinstated"
    end

    it "should report something useful if the Alert can't be saved" do
      ValidationAlert.stub(:create!).and_raise("something went wrong")
      post :clear, params
      expect(response.status).to eq 500
      expect(JSON.parse response.body).to include "message" => "something went wrong"
    end
  end
end
