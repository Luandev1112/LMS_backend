class LanguageResource < JSONAPI::Resource

  attributes :name, :created_at, :updated_at
  
  has_many :language_users,
    exclude_links: :default
    
  exclude_links :default
end