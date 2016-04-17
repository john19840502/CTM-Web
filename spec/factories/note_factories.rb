FactoryGirl.define do
  factory :note do
    body 'Ooops something went wrong.'
    #association :noteable, :factory => :loan
  end
end
