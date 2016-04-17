require "spec_helper"

describe ApplicationController do
  #This creates an anonymous subclass of ApplicationController to test the functionality
  controller do
    def index
      render :text => "index called"
    end

    def new
      permission_denied
    end
  end

  # describe 'forcing correct subdomains' do
  #   context 'admin user is logged in' do
  #     before do
  #       u = fake_rubycas_login
  #       u.stub(:roles).and_return('admin')
  #     end

  #     describe 'and goes to a page on test.host' do
  #       before do
  #         get :index
  #       end

  #       it { should redirect_to 'http://admin.test.host' }
  #     end

  #     describe 'and goes to a page on test.host.enterprise.coletaylor.com' do
  #       before do
  #         request.host = 'test.host.enterprise.coletaylor.com'
  #         get :index
  #       end

  #       it { should redirect_to 'http://admin.test.host' }
  #     end
  #   end
  # end

  describe "filtering based on logging in" do
    context "user is not logged in" do
      describe "go to a page" do
        before do
          ensure_nobody_logged_in
          get :index
        end

        it "should require you to log in" do
          response.should redirect_to 'rubycas_should_be_stubbed_out/login?service=http%3A%2F%2Ftest.host%2Fanonymous'
        end
      end
    end

    context "user is logged in" do
      before do
        fake_rubycas_login
      end

      describe "go to a page" do
        before { get :index }
        it "should go to the page" do
          response.body.should include "index called"
        end

        its(:logged_in?) { should be true }
      end
    end
  end

  describe "#permission_denied" do
    before do
      fake_rubycas_login
      request.env["HTTP_REFERER"] = 'backhome'
      get :new
    end

    it { should redirect_to 'backhome' }
  end

end
