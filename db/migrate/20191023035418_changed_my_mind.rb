class ChangedMyMind < ActiveRecord::Migration[6.0]
  def down
    execute <<-SQL
      CREATE TYPE availability_statuses AS ENUM ('morning', 'afternoon', 'evening');
      ALTER TABLE users ALTER COLUMN availability TYPE availability_statuses USING availability::availability_statuses
    SQL
  end

  def up 
    change_column :users, :availability, :string
  end
end
