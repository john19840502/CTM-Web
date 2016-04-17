FactoryGirl.define do
  factory :branch_compensation do
    name 'Test Plan'
    branch Institution.first
    after(:create) do |compensation|
      FactoryGirl.create(:branch_compensation_detail, branch_compensation: compensation)
    end
  end
end
