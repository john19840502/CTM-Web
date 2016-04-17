FactoryGirl.define do
  factory :datamart_user do
    after(:create) do |dtuser|
      FactoryGirl.create(:datamart_user_profile, institution_id: Institution.first.id, datamart_user_id: dtuser.id, effective_date: 1.day.ago)
    end
  end
end
