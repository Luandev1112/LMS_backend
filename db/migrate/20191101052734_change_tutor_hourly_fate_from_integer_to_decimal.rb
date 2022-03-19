class ChangeTutorHourlyFateFromIntegerToDecimal < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :hourly_rate, :decimal
  end
end
