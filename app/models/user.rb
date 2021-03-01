class User < ApplicationRecord
  has_secure_password
  has_many :roles, dependent: :destroy
  has_many :commit_adjustments, dependent: :destroy
  validates :email, uniqueness: { case_sensitive: false }
end
