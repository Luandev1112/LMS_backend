FactoryBot.define do 
  factory :availability do
    name { Faker::FunnyName.name_with_initial }
  end  
end