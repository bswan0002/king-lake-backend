class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :square_id, :roles
end
