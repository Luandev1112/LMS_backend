class CreateTutorAvailabilities < ActiveRecord::Migration[6.0]
  def change

    create_table :availabilities do |t|
      t.string :name
      t.timestamps
    end

    create_table :tutor_availabilities do |t|
      t.references :tutor
      t.references :availability
      t.timestamps
    end

    remove_column :users, :availability, :string
  end
end
