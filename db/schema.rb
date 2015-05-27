# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150527033320) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "filmed_ats", force: :cascade do |t|
    t.integer  "movie_id"
    t.integer  "location_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "filmed_ats", ["location_id"], name: "index_filmed_ats_on_location_id", using: :btree
  add_index "filmed_ats", ["movie_id"], name: "index_filmed_ats_on_movie_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "movies", force: :cascade do |t|
    t.string   "title"
    t.datetime "release_year"
    t.text     "fun_fact"
    t.string   "production_company"
    t.string   "distributor"
    t.string   "director"
    t.string   "writer"
    t.string   "actor1"
    t.string   "actor2"
    t.string   "actor3"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "movies", ["title"], name: "index_movies_on_title", using: :btree

end
