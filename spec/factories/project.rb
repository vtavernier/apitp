FactoryGirl.define do
  sequence :project_name do |n|
    "TP#{(Project.maximum(:id) || 0) + 1}"
  end

  factory :project do
    year { SchoolDateHelper.school_year }
    name { generate(:project_name) }
    start_time { Faker::Date.between(Date.today - 5.days, Date.today - 1.day) }
    end_time { Faker::Date.between(Date.today + 1.day, Date.today + 5.days) }
    url { FFaker::Internet.http_url }
    max_upload_size { FFaker::Random.rand(Rails.configuration.x.apitp.max_upload_size / 2) + Rails.configuration.x.apitp.max_upload_size / 4 }
    association :owner, factory: :admin_user
  end
end
