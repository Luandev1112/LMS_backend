class SavedProfileResource < JSONAPI::Resource

  attributes :created_at, :updated_at

  has_one :saver,
    class_name: 'Student',
    foreign_key: :saver_id,
    exclude_links: :default
  has_one :savee,
    class_name: 'Tutor',
    foreign_key: :savee_id,
    exclude_links: :default
   
  exclude_links :default 
end