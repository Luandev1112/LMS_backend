# https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#single-table-inheritance
require "sti_preload"

class User < ApplicationRecord
  include StiPreload

  include Rails.application.routes.url_helpers

  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, 
    :validatable, :lastseenable, :jwt_authenticatable, 
    jwt_revocation_strategy: JWTBlacklist

  has_many :language_users, 
    inverse_of: :user
  has_many :languages, 
    through: :language_users, 
    inverse_of: :users
  has_many :received_messages,
    foreign_key: :messagee_id,
    class_name: 'Message', 
    inverse_of: :messagee
  has_many :sent_messages,
    foreign_key: :messager_id,
    class_name: 'Message',
    inverse_of: :messager
  belongs_to :postcode,
    inverse_of: :users, 
    optional: true

  # User registration was straight-up ignoring :password_registration. Search me why.
  # https://stackoverflow.com/questions/15661815/devise-and-password-confirmation-validation 
  # covered how to add it again.
  validates :password_confirmation, presence: true, on: :create

  has_one_base64_attached :profile_image

  accepts_nested_attributes_for :language_users

  acts_as_mappable through: :postcode

  unless Rails.application.config.eager_load
    def self.find_sti_class(type)
      return User if type.to_s == 'User'
      return Tutor if type.to_s == 'Tutor'
      return Student if type.to_s == 'Student'
    end
  end
end