class SubjectTutor < ApplicationRecord

  belongs_to :subject, inverse_of: :subject_tutors
  belongs_to :tutor, inverse_of: :subject_tutors
end