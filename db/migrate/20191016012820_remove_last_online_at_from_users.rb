class RemoveLastOnlineAtFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :last_online_at
  end
end
