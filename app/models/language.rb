class Language < ApplicationRecord

  has_many :language_users, inverse_of: :language
  has_many :users, through: :language_user, inverse_of: :languages
end