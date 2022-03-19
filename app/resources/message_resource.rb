class MessageResource < JSONAPI::Resource

  attributes :content, :seen_at, :created_at, :updated_at

  has_one :messager,
    class_name: 'User',
    foreign_key: :messager_id,
    exclude_links: :default
  has_one :messagee,
    class_name: 'User',
    foreign_key: :messagee_id,
    exclude_links: :default

  exclude_links :default
    
end