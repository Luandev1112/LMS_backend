FactoryBot.define do
  factory :review do
    content { Faker::Movies::BackToTheFuture.quote }
    rating { Faker::Number.betweeen(from: 1, to: 10) }

    reviewer
    reviewee
  end
end