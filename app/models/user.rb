class User < ApplicationRecord
  has_secure_password
  has_many :roles, dependent: :destroy
  has_many :commit_adjustments, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :items, through: :orders
  validates :email, uniqueness: { case_sensitive: false }
end
