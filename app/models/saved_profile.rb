# Join objects. These let Students keep track of Tutors. 

class SavedProfile < ApplicationRecord

  belongs_to :saver, 
    class_name: 'Student', 
    inverse_of: :saved_profiles, 
    foreign_key: :saver_id
  belongs_to :savee, 
    class_name: 'Tutor', 
    inverse_of: :saved_profiles,
    foreign_key: :savee_id

end