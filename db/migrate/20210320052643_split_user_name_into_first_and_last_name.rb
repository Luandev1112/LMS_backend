class SplitUserNameIntoFirstAndLastName < ActiveRecord::Migration[6.0]
  def up
    change_table :users do |t|
      t.string :first_name
      t.string :last_name
    end

    User.find_each do |user|
      next if user.name.blank?
      user.first_name = user.name.split(' ').first
      user.last_name = user.name.split(' ').last
      user.save
    end

    remove_column :users, :name
  end

  def down
    add_column :users, :name, :string

    User.find_each do |user|
      user.name = "#{user.first_name} #{user.last_name}"
      user.save
    end

    remove_column :users, :first_name
    remove_column :users, :last_name
  end
end
