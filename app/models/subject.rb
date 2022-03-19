class Subject < ApplicationRecord

  has_many :student_subjects, inverse_of: :subject
  has_many :students, through: :student_subject, inverse_of: :subjects
  has_many :subject_tutors, inverse_of: :subject
  has_many :tutors, through: :subject_tutor, inverse_of: :subjects


end