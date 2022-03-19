class Student < User

  has_many :saved_profiles, 
    inverse_of: :saver, 
    foreign_key: :saver_id
  has_many :saved_tutors, 
    through: :saved_profiles, 
    inverse_of: :saved_students,
    source: :savee
  has_many :student_subjects, inverse_of: :student
  has_many :subjects, through: :student_subject, inverse_of: :students
  has_many :reviews, inverse_of: :reviewer, foreign_key: :reviewer_id
end