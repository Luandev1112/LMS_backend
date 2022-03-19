FactoryBot.define do 
  factory :language do
    name { Faker::Books::CultureSeries.culture_ship }
  end  
end