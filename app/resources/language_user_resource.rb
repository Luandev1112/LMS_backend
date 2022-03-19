class LanguageUserResource < JSONAPI::Resource

  attributes :created_at, :updated_at
  
  has_one :language,
    exclude_links: :default
  has_one :user,
    exclude_links: :default
  
  exclude_links :default
end