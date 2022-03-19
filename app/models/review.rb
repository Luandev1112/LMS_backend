class Review < ApplicationRecord

  belongs_to :reviewer, 
    class_name: 'Student', 
    inverse_of: :reviews,
    foreign_key: :reviewer_id
  belongs_to :reviewee, 
    class_name: 'Tutor', 
    inverse_of: :reviews,
    foreign_key: :reviewee_id
end