class SubjectResource < JSONAPI::Resource

  attributes :name

  has_many :student_subjects,
    exclude_links: :default
  has_many :student_tutors,
    exclude_links: :default

  exclude_links :default
end
