FactoryGirl.define do
  factory :branch_compensation_detail do
    effective_date Date.today
    lo_min 300
    lo_max 10000
  end
end
