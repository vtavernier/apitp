FactoryGirl.define do
  factory :admin_user do
    name     { FFaker::Name.unique.name }
    email    { FFaker::Internet.unique.email }
    password { FFaker::Internet.password }

    trait :super_admin do
      super_admin true
    end

    factory :super_admin_user, traits: [ :super_admin ]
  end
end
