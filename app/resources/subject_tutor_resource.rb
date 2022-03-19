class SubjectTutorResource < JSONAPI::Resource

  attributes :created_at, :updated_at

  has_one :subject,
    always_include_linkage_data: true,
    exclude_links: :default
  has_one :tutor, 
    always_include_linkage_data: true,
    exclude_links: :default

  exclude_links :default
end
