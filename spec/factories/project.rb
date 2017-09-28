FactoryGirl.define do
  sequence :project_name do |n|
    "TP#{n}"
  end

  factory :project do
    year { SchoolDateHelper.school_year }
    name { generate(:project_name) }
    start_time { FFaker::Time.between(DateTime.now - 5.days, DateTime.now - 1.day) }
    end_time { FFaker::Time.between(DateTime.now + 1.day, DateTime.now + 5.days) }
    url { FFaker::Internet.http_url }
    max_upload_size { FFaker::Random.rand(Rails.configuration.x.apitp.max_upload_size / 2) + Rails.configuration.x.apitp.max_upload_size / 4 }
    association :owner, factory: :admin_user
  end
end
