FactoryBot.define do
  factory :postcode do
    code { Faker::Number.number(digits: 4).to_s }
    name { Faker::Cannabis.brand }
    state { Faker::Address.state }
    county { Faker::Address.country }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
  end
end