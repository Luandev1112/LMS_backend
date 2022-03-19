class StudentSubject < ApplicationRecord

  belongs_to :student, inverse_of: :student_subjects
  belongs_to :subject, inverse_of: :student_subjects
end