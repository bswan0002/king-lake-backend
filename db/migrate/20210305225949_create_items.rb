class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :items do |t|
      t.references :order, null: false, foreign_key: true
      t.string :wine
      t.integer :quantity

      t.timestamps
    end
  end
end
