FactoryGirl.define do
  factory :loan do 
    loan_general
    
    factory :funded do
      is_funded true
    end
  end
end
