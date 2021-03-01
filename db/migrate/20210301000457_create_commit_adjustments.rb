class CreateCommitAdjustments < ActiveRecord::Migration[6.1]
  def change
    create_table :commit_adjustments do |t|
      t.integer :adjustment
      t.text :note
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
