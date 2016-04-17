FactoryGirl.define do
  factory :user do
    sequence(:login) { |n| "person#{n}" }
    sequence(:distinguished_name) { |n| "person#{n}" }
    temp_org { 'admin' }
    uuid { UUIDTools::UUID.random_create.to_s }
  end
end
