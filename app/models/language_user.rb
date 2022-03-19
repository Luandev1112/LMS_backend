class LanguageUser < ApplicationRecord

  belongs_to :language, inverse_of: :language_users
  belongs_to :user, inverse_of: :language_users

end