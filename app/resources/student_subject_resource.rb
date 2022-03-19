class StudentSubjectResource < JSONAPI::Resource

  attributes :created_at, :updated_at

  has_one :student,
    exclude_links: :default
  has_one :subject,
    exclude_links: :default

  exclude_links :default
end