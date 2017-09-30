FactoryGirl.define do
  sequence :group_name do |n|
    "#{["TD", "CM"].sample} #{(Group.maximum(:id) || 0) + 1}"
  end

  factory :group do
    year { SchoolDateHelper.school_year }
    name { generate(:group_name) }
    association :admin, factory: :admin_user
  end
end
