FactoryBot.define do
  factory :saved_profile do
    association :saver, factory: :student
    association :savee, factory: :tutor
  end
end