class ChangeTutorAvailabiltyFromStringToEnum < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE TYPE availability_statuses AS ENUM ('morning', 'afternoon', 'evening');
      ALTER TABLE users ALTER COLUMN availability TYPE availability_statuses USING availability::availability_statuses
    SQL
  end

  def down 
    change_column :users, :availability, :string
  end
end
