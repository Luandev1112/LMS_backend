class CreatePostcodes < ActiveRecord::Migration[6.0]
  def change
    create_table :postcodes do |t|
      t.string :code
      t.string :name
      t.string :state
      t.string :county
      t.float :latitude
      t.float :longitude
    end

    remove_column :users, :postcode
    add_column :users, :postcode_id, :integer
    add_foreign_key :users, :postcodes, column: :postcode_id 
  end
end
