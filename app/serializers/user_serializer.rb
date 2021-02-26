class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :square_id, :commit_count, :roles
end
