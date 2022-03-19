class AvailabilityResource < JSONAPI::Resource

  attributes :name, :created_at, :updated_at
  
  has_many :tutor_availabilities,
    exclude_links: :default

  exclude_links :default
end