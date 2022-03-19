class OopsForgotTimestampsForPostcodesToo < ActiveRecord::Migration[6.0]
  def change
    change_table :postcodes do |t|
      t.datetime :created_at, null: false, default: DateTime.now
      t.datetime :updated_at, null: false, default: DateTime.now
    end
  end
end
