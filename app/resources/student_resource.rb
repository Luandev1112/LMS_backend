class StudentResource < UserResource

  has_many :saved_profiles,
    foreign_key: :saver_id,
    exclude_links: :default
  has_many :student_subjects,
    exclude_links: :default
  has_many :reviews,
    exclude_links: :default

end