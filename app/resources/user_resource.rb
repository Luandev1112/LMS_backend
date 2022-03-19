class UserResource < JSONAPI::Resource
  include Rails.application.routes.url_helpers

  attributes :created_at, :updated_at, :email, :first_name, :last_name, :sex, :age, :last_seen, :profile_image_path
  
  has_many :languages,
    exclude_links: :default
  has_many :received_messages,
    foreign_key: 'messagee_id',
    class_name: 'Message',
    exclude_links: :default
  has_many :sent_messages,
    foreign_key: 'messager_id',
    class_name: 'Message',
    exclude_links: :default
  has_one :postcode,
    exclude_links: :default

  exclude_links :default
  
  # Getter? https://jsonapi-resources.com/v0.10/guide/resources.html#Flattening-a-Rails-relationship
  def profile_image_path
    if @model.profile_image.blank?
      nil
    else
      rails_blob_path(@model.profile_image, only_path: true)
    end
  end


  # 'languages' is a comma-separated list of language IDs.
  # Remember: Users have-and-belong-to-many Languages.
  filter :languages,
    verify: -> (values, _context) { values.map(&:to_i) },
    apply: -> (records, ids, _options) {
      return records if ids.length == 0

      records = records.includes(language_users: :languages)
                       .joins(language_users: :languages)
                       .where('languages.id IN (?)', ids)
    }

end
