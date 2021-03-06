class OrderSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :pickup_date, :prepared, :paid_for, :picked_up, :items
end
