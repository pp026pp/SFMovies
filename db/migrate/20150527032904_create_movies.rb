class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string   :title, index: true
      t.datetime :release_year
      t.text     :fun_fact
      t.string   :production_company
      t.string   :distributor
      t.string   :director
      t.string   :writer
      t.string   :actor1
      t.string   :actor2
      t.string   :actor3
      t.timestamps null: false
    end
  end
end
