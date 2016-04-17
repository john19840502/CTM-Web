require "spec_helper"

describe Accounting::DatamartUserProfilesController do

  before do
    fake_rubycas_login
  end

  render_views

  it "get :new should not crash" do
    get :new, uid: 6963, bid: 786
    response.status.should == 200
  end

  it "post :create should not crash" do
    post :create, { datamart_user_profile: { datamart_user_id: 6963, institution_id: 786 } }
    response.status.should == 200
  end

  it "post :create with bad data should not crash" do
    the_date = Date.new(2010, 1, 23)
    Date.stub today: the_date

    post :create, { datamart_user_profile: { 
      datamart_user_id: 6963, 
      institution_id: 786 ,
      effective_date: '2001-01-23'
    } }
    expect(flash[:error]).to include('Effective date must be on or after 2009-01-23 00:00:00')
  end
end
