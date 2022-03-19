class AddCoreTables < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.timestamp :last_online_at
      t.string :sex
      t.integer :age
      t.string :postcode
      t.integer :max_distance_available
      t.integer :hourly_rate
      t.string :availability
      t.text :biography
      t.timestamps
    end

    create_table :subjects do |t|
      t.string :name
      t.timestamps
    end

    create_table :languages do |t|
      t.string :name
      t.timestamps
    end

    create_table :subject_tutors do |t|
      t.references :subject
      t.references :tutor, foreign_key: { to_table: 'users' }
      t.timestamps
    end

    create_table :student_subjects do |t|
      t.references :student, foreign_key: { to_table: 'users' }
      t.references :subject
      t.timestamps
    end

    create_table :saved_profiles do |t|
      t.references :saver, foreign_key: { to_table: 'users' }
      t.references :savee, foreign_key: { to_table: 'users' }
      t.timestamps
    end

    create_table :reviews do |t|
      t.text :content
      t.integer :rating
      t.references :reviewer, foreign_key: { to_table: 'users' }
      t.references :reviewee, foreign_key: { to_table: 'users' }
      t.timestamps
    end

    create_table :messages do |t|
      t.text :content
      t.timestamp :seen_at
      t.references :messager, foreign_key: { to_table: 'users' }
      t.references :messagee, foreign_key: { to_table: 'users' }
      t.timestamps
    end
  end
end
