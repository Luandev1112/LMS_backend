class TutorAvailability < ApplicationRecord

  belongs_to :tutor, inverse_of: :tutor_availabilities
  belongs_to :availability, inverse_of: :tutor_availabilities
end