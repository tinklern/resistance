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

ActiveRecord::Schema.define(version: 20130723162131) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: true do |t|
    t.string   "name"
    t.boolean  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "neg_score",        default: 0
    t.integer  "pos_score",        default: 0
    t.integer  "current_round_id"
    t.integer  "state",            default: 0
  end

  create_table "players", force: true do |t|
    t.string   "name"
    t.integer  "game_id"
    t.integer  "loyalty"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "auth_hash"
    t.boolean  "is_ready",   default: false
  end

  create_table "rounds", force: true do |t|
    t.integer  "leader_id"
    t.text     "team_ids"
    t.integer  "yes_votes"
    t.integer  "no_votes"
    t.integer  "pass_votes"
    t.integer  "fail_votes"
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "who_voted"
  end

end
