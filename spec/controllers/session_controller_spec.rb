require "spec_helper"

describe SessionController do
  context 'no user is logged in' do
    describe 'delete :destroy' do
      before do
        ensure_nobody_logged_in
        delete :destroy
      end

      it { should redirect_to 'rubycas_should_be_stubbed_out/login?service=http%3A%2F%2Ftest.host%2Flogout' }
      it "should set current user to nil" do
        assigns(:current_user).should == nil
      end

      it "should set extra attributes to nil" do
        assigns(:extra_attributes).should == nil
      end
    end
  end

  context 'a user is logged in' do
    before do
      fake_rubycas_login
    end

    describe 'delete :destroy' do
      before do
        delete :destroy
      end

      it { should redirect_to 'rubycas_should_be_stubbed_out/logout?destination=http%3A%2F%2Ftest.host%2F&gateway=true' }
      it "should set current user to nil" do
        assigns(:current_user).should == nil
      end

      it "should set extra attributes to nil" do
        assigns(:extra_attributes).should == nil
      end
    end
  end
end
