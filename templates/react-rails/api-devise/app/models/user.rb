class User < ApplicationRecord
  # :validatable covers email presence/uniqueness/format and password length
  # (bounds live in config/initializers/devise.rb). Add modules as features
  # land: :recoverable, :confirmable, :lockable, :trackable, :rememberable.
  devise :database_authenticatable, :registerable, :validatable
end
