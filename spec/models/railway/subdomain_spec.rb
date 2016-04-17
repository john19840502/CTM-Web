require 'spec_helper'

describe Subdomain do
  
  describe 'no name has been added' do
    let(:subdomain) { Subdomain.new }
    its(:valid?) { should be false }
  end
  
  describe 'a name has been added' do
    subject { Subdomain.new({:name => 'FooBarBaz'}, without_protection: true) }
    its(:valid?) { should be true }
  end
  
  # describe 'instance methods' do
  #   
  #   subject { create :subdomain }
  #   its(:name) { should be_a String }
  #   
  #   
  #   smoke_test :name
  #   smoke_test :groups
  # end
end
