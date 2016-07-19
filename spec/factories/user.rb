FactoryGirl.define do
  factory :user do
    sequence(:username) { |i| "example#{i}" }
    sequence(:email) { |i| "example#{i}@example.com" }
  end
end
