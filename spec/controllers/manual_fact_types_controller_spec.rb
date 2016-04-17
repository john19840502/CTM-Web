require 'spec_helper'

describe ManualFactTypesController do
  before do
    fake_rubycas_login
    ManualFactType.delete_all
  end

  describe 'post :save #right_to_delay facttype' do
    stuff = { :id => '12345',
      manual_fact_types: { "right_to_delay" => "09/10/2010"}
    }

    it "should create manual fact type with name right_to_delay" do
      post 'save', stuff.merge(format: :json)

      expect(response.status).to eq 200
      expect(JSON.parse(response.body).first["name"]).to eq "right_to_delay"
      expect(JSON.parse(response.body).first["value"]).to eq "09/10/2010"
      expect(JSON.parse(response.body).first["loan_num"]).to eq 12345
    end
  end

  describe "post :save #texas_only facttype" do
    stuff = { :id => '54321',
      manual_fact_types: { "texas_only" => "Yes"}
    }

    it "should create manual fact type with name texas_only" do
      post 'save', stuff.merge(format: :json)

      expect(response.status).to eq 200
      expect(JSON.parse(response.body).first["name"]).to eq "texas_only"
      expect(JSON.parse(response.body).first["value"]).to eq "Yes"
      expect(JSON.parse(response.body).first["loan_num"]).to eq 54321
    end
  end
end