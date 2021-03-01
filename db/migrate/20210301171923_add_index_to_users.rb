class AddIndexToUsers < ActiveRecord::Migration[6.1]
  def change
    add_index :users, :square_id
  end
end
