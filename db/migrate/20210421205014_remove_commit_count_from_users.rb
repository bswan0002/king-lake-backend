class RemoveCommitCountFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :commit_count
  end
end
