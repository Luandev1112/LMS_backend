FactoryBot.define do
  factory :message do
    content { Faker::Movies::HitchhikersGuideToTheGalaxy.quote }
    seen_at { Faker::Time.between(from: DateTime.now - 6.weeks, to: DateTime.now + 6.weeks) }

    messager factory: :user
    messagee factory: :user
  end
end