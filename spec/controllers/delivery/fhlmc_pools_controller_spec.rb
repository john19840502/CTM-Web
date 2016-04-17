require 'spec_helper'

describe Delivery::FhlmcPoolsController do
  render_views

  before do
    u = fake_rubycas_login
  end

  describe "GET 'index'" do
    before do
      get :index
    end

    it { should render_template 'index' }
  end

  describe 'get :filter_by_date' do
    before do
      get :filter_by_date, start_date: '01-01-2012', end_date: '01-02-2012'
    end

    it { should render_template 'filter_by_date' }
  end

  describe 'get :export' do
    let(:loans) { [] }
    let(:pool) { double('pool') }
    before do 
      pool.stub loans: loans, originator: nil, investor_commitment_number: 'aslfjf'
      ActiveRecord::Relation.any_instance.stub(:find).with('123').and_return(pool)
      get :export, { format: 'xml', record_id: '123' }
    end

    it { should render_template 'export' }
  end
end
