class AddAttributesToOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :prepared, :boolean
    add_column :orders, :paid_for, :boolean
    add_column :orders, :picked_up, :boolean
  end
end
