class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :square_id
      t.integer :commit_count

      t.timestamps
    end
  end
end
