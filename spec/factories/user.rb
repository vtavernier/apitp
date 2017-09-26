FactoryGirl.define do
  factory :user do
    name     { FFaker::Name.unique.name }
    email    { FFaker::Internet.unique.email }
    password { FFaker::Internet.password }
  end
end
