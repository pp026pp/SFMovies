class CreateFilmedAts < ActiveRecord::Migration
  def change
    create_table :filmed_ats do |t|
      t.references :movie,    index: true
      t.references :location, index: true

      t.timestamps null: false
    end
  end
end
