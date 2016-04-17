require "spec_helper"

describe Closing::ScheduledFundingsController do
  render_views

  let(:instancey) { build_stubbed :scheduled_funding }

  before do
    fake_rubycas_login
  end

  describe 'get :index' do
    before do
      get :index
    end

    it { should render_template 'index' }
  end

  describe 'get :filter_by_date' do
    before do
      get :filter_by_date, :start_date => Date.today, :end_date => Date.today
    end

    it { should render_template 'filter_by_date'}
  end

end
