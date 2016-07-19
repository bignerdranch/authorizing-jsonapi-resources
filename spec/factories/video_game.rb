FactoryGirl.define do
  factory :video_game do
    user

    sequence(:title) { |i| "Ultimate Pretend #{i}" }
  end
end
