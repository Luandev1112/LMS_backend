class Availability < ApplicationRecord

  has_many :tutor_availabilities, inverse_of: :availability
  has_many :tutors, through: :tutor_availabilities, inverse_of: :availabilities

  VALUES = ['morning', 'afternoon', 'evening']
end
