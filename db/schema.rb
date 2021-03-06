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

ActiveRecord::Schema.define(version: 20170625174646) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.decimal "balance_due", precision: 10, scale: 2, default: 0.0, null: false
    t.integer "cluster_id", null: false
    t.integer "community_id", null: false
    t.datetime "created_at", null: false
    t.decimal "credit_limit", precision: 10, scale: 2
    t.decimal "current_balance", precision: 10, scale: 2, default: 0.0, null: false
    t.decimal "due_last_statement", precision: 10, scale: 2
    t.integer "household_id", null: false
    t.integer "last_statement_id"
    t.date "last_statement_on"
    t.decimal "total_new_charges", precision: 10, scale: 2, default: 0.0, null: false
    t.decimal "total_new_credits", precision: 10, scale: 2, default: 0.0, null: false
    t.datetime "updated_at", null: false
  end

  add_index "accounts", ["cluster_id"], name: "index_accounts_on_cluster_id", using: :btree
  add_index "accounts", ["community_id", "household_id"], name: "index_accounts_on_community_id_and_household_id", unique: true, using: :btree
  add_index "accounts", ["community_id"], name: "index_accounts_on_community_id", using: :btree
  add_index "accounts", ["household_id"], name: "index_accounts_on_household_id", using: :btree

  create_table "assignments", force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.datetime "created_at", null: false
    t.integer "meal_id", null: false
    t.integer "reminder_count", default: 0, null: false
    t.string "role", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
  end

  add_index "assignments", ["cluster_id"], name: "index_assignments_on_cluster_id", using: :btree
  add_index "assignments", ["meal_id", "role", "user_id"], name: "index_assignments_on_meal_id_and_role_and_user_id", unique: true, using: :btree
  add_index "assignments", ["meal_id"], name: "index_assignments_on_meal_id", using: :btree
  add_index "assignments", ["role"], name: "index_assignments_on_role", using: :btree
  add_index "assignments", ["user_id"], name: "index_assignments_on_user_id", using: :btree

  create_table "clusters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  add_index "clusters", ["name"], name: "index_clusters_on_name", using: :btree

  create_table "communities", force: :cascade do |t|
    t.string "abbrv", limit: 2
    t.integer "cluster_id"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.jsonb "settings"
    t.string "slug", null: false
    t.datetime "updated_at", null: false
  end

  add_index "communities", ["cluster_id"], name: "index_communities_on_cluster_id", using: :btree
  add_index "communities", ["name"], name: "index_communities_on_name", unique: true, using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at"
    t.datetime "failed_at"
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "locked_at"
    t.string "locked_by"
    t.integer "priority", default: 0, null: false
    t.string "queue"
    t.datetime "run_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "households", force: :cascade do |t|
    t.string "alternate_id"
    t.integer "cluster_id", null: false
    t.integer "community_id", null: false
    t.datetime "created_at", null: false
    t.datetime "deactivated_at"
    t.string "garage_nums"
    t.string "name", limit: 50, null: false
    t.integer "unit_num"
    t.datetime "updated_at", null: false
  end

  add_index "households", ["cluster_id"], name: "index_households_on_cluster_id", using: :btree
  add_index "households", ["community_id", "name"], name: "index_households_on_community_id_and_name", unique: true, using: :btree
  add_index "households", ["community_id"], name: "index_households_on_community_id", using: :btree
  add_index "households", ["deactivated_at"], name: "index_households_on_deactivated_at", using: :btree
  add_index "households", ["name"], name: "index_households_on_name", using: :btree

  create_table "invitations", force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.integer "community_id", null: false
    t.integer "meal_id", null: false
  end

  add_index "invitations", ["cluster_id"], name: "index_invitations_on_cluster_id", using: :btree
  add_index "invitations", ["community_id", "meal_id"], name: "index_invitations_on_community_id_and_meal_id", unique: true, using: :btree
  add_index "invitations", ["community_id"], name: "index_invitations_on_community_id", using: :btree
  add_index "invitations", ["meal_id"], name: "index_invitations_on_meal_id", using: :btree

  create_table "meals", force: :cascade do |t|
    t.text "allergens", default: "[]", null: false
    t.integer "capacity", null: false
    t.integer "cluster_id", null: false
    t.integer "community_id", null: false
    t.datetime "created_at", null: false
    t.integer "creator_id", null: false
    t.text "dessert"
    t.decimal "discount", precision: 5, scale: 2, default: 0.0, null: false
    t.text "entrees"
    t.text "kids"
    t.text "notes"
    t.datetime "served_at", null: false
    t.text "side"
    t.string "status", default: "open", null: false
    t.string "title"
    t.datetime "updated_at", null: false
  end

  add_index "meals", ["cluster_id"], name: "index_meals_on_cluster_id", using: :btree
  add_index "meals", ["creator_id"], name: "index_meals_on_creator_id", using: :btree
  add_index "meals", ["served_at"], name: "index_meals_on_served_at", using: :btree

  create_table "meals_costs", force: :cascade do |t|
    t.decimal "adult_meat", precision: 10, scale: 2
    t.decimal "adult_veg", precision: 10, scale: 2
    t.decimal "big_kid_meat", precision: 10, scale: 2
    t.decimal "big_kid_veg", precision: 10, scale: 2
    t.integer "cluster_id", null: false
    t.datetime "created_at", null: false
    t.decimal "ingredient_cost", precision: 10, scale: 2, null: false
    t.decimal "little_kid_meat", precision: 10, scale: 2
    t.decimal "little_kid_veg", precision: 10, scale: 2
    t.string "meal_calc_type"
    t.integer "meal_id", null: false
    t.string "pantry_calc_type"
    t.decimal "pantry_cost", precision: 10, scale: 2, null: false
    t.decimal "pantry_fee", precision: 10, scale: 2
    t.string "payment_method", null: false
    t.decimal "senior_meat", precision: 10, scale: 2
    t.decimal "senior_veg", precision: 10, scale: 2
    t.decimal "teen_meat", precision: 10, scale: 2
    t.decimal "teen_veg", precision: 10, scale: 2
    t.datetime "updated_at", null: false
  end

  add_index "meals_costs", ["cluster_id"], name: "index_meals_costs_on_cluster_id", using: :btree
  add_index "meals_costs", ["meal_id"], name: "index_meals_costs_on_meal_id", using: :btree

  create_table "meals_formulas", force: :cascade do |t|
    t.decimal "adult_meat", precision: 10, scale: 2
    t.decimal "adult_veg", precision: 10, scale: 2
    t.decimal "big_kid_meat", precision: 10, scale: 2
    t.decimal "big_kid_veg", precision: 10, scale: 2
    t.integer "cluster_id", null: false
    t.integer "community_id", null: false
    t.date "effective_on", null: false
    t.decimal "little_kid_meat", precision: 10, scale: 2
    t.decimal "little_kid_veg", precision: 10, scale: 2
    t.string "meal_calc_type", null: false
    t.string "pantry_calc_type"
    t.decimal "pantry_fee", precision: 10, scale: 2
    t.decimal "senior_meat", precision: 10, scale: 2
    t.decimal "senior_veg", precision: 10, scale: 2
    t.decimal "teen_meat", precision: 10, scale: 2
    t.decimal "teen_veg", precision: 10, scale: 2
  end

  add_index "meals_formulas", ["cluster_id"], name: "index_meals_formulas_on_cluster_id", using: :btree
  add_index "meals_formulas", ["community_id"], name: "index_meals_formulas_on_community_id", using: :btree
  add_index "meals_formulas", ["effective_on"], name: "index_meals_formulas_on_effective_on", using: :btree

  create_table "meals_messages", force: :cascade do |t|
    t.text "body", null: false
    t.integer "cluster_id", null: false
    t.datetime "created_at", null: false
    t.integer "meal_id", null: false
    t.string "recipient_type", null: false
    t.integer "sender_id", null: false
    t.datetime "updated_at", null: false
  end

  create_table "old_credit_balances", id: false, force: :cascade do |t|
    t.decimal "balance", precision: 5, scale: 2
    t.integer "community_program_id", default: 2
    t.string "name", limit: 65
    t.integer "new_id"
    t.decimal "old_id", precision: 6
  end

  create_table "people_emergency_contacts", force: :cascade do |t|
    t.string "alt_phone"
    t.integer "cluster_id", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.integer "household_id"
    t.string "location", null: false
    t.string "main_phone", null: false
    t.string "name", null: false
    t.string "relationship", null: false
    t.datetime "updated_at", null: false
  end

  add_index "people_emergency_contacts", ["cluster_id"], name: "index_people_emergency_contacts_on_cluster_id", using: :btree
  add_index "people_emergency_contacts", ["household_id"], name: "index_people_emergency_contacts_on_household_id", using: :btree

  create_table "people_guardianships", force: :cascade do |t|
    t.integer "child_id"
    t.integer "cluster_id", null: false
    t.datetime "created_at", null: false
    t.integer "guardian_id"
    t.datetime "updated_at", null: false
  end

  add_index "people_guardianships", ["child_id"], name: "index_people_guardianships_on_child_id", using: :btree
  add_index "people_guardianships", ["cluster_id"], name: "index_people_guardianships_on_cluster_id", using: :btree
  add_index "people_guardianships", ["guardian_id"], name: "index_people_guardianships_on_guardian_id", using: :btree

  create_table "people_vehicles", force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.string "color"
    t.datetime "created_at", null: false
    t.integer "household_id"
    t.string "make"
    t.string "model"
    t.datetime "updated_at", null: false
  end

  add_index "people_vehicles", ["cluster_id"], name: "index_people_vehicles_on_cluster_id", using: :btree
  add_index "people_vehicles", ["household_id"], name: "index_people_vehicles_on_household_id", using: :btree

  create_table "reservation_guideline_inclusions", force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.integer "resource_id", null: false
    t.integer "shared_guidelines_id", null: false
  end

  add_index "reservation_guideline_inclusions", ["cluster_id"], name: "index_reservation_guideline_inclusions_on_cluster_id", using: :btree
  add_index "reservation_guideline_inclusions", ["resource_id", "shared_guidelines_id"], name: "index_reservation_guideline_inclusions", unique: true, using: :btree

  create_table "reservation_protocolings", force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.datetime "created_at", null: false
    t.integer "protocol_id", null: false
    t.integer "resource_id", null: false
    t.datetime "updated_at", null: false
  end

  add_index "reservation_protocolings", ["cluster_id"], name: "index_reservation_protocolings_on_cluster_id", using: :btree
  add_index "reservation_protocolings", ["resource_id", "protocol_id"], name: "protocolings_unique", unique: true, using: :btree

  create_table "reservation_protocols", force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.integer "community_id", null: false
    t.datetime "created_at", null: false
    t.time "fixed_end_time"
    t.time "fixed_start_time"
    t.boolean "general", default: false, null: false
    t.string "kinds"
    t.integer "max_days_per_year"
    t.integer "max_lead_days"
    t.integer "max_length_minutes"
    t.integer "max_minutes_per_year"
    t.string "other_communities"
    t.text "pre_notice"
    t.boolean "requires_kind"
    t.datetime "updated_at", null: false
  end

  add_index "reservation_protocols", ["cluster_id"], name: "index_reservation_protocols_on_cluster_id", using: :btree
  add_index "reservation_protocols", ["community_id"], name: "index_reservation_protocols_on_community_id", using: :btree

  create_table "reservation_resourcings", force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.integer "meal_id", null: false
    t.integer "prep_time", null: false
    t.integer "resource_id", null: false
    t.integer "total_time", null: false
  end

  add_index "reservation_resourcings", ["cluster_id"], name: "index_reservation_resourcings_on_cluster_id", using: :btree
  add_index "reservation_resourcings", ["meal_id", "resource_id"], name: "index_reservation_resourcings_on_meal_id_and_resource_id", unique: true, using: :btree

  create_table "reservation_shared_guidelines", force: :cascade do |t|
    t.text "body", null: false
    t.integer "cluster_id", null: false
    t.integer "community_id", null: false
    t.datetime "created_at", null: false
    t.string "name", limit: 64, null: false
    t.datetime "updated_at", null: false
  end

  add_index "reservation_shared_guidelines", ["cluster_id"], name: "index_reservation_shared_guidelines_on_cluster_id", using: :btree
  add_index "reservation_shared_guidelines", ["community_id"], name: "index_reservation_shared_guidelines_on_community_id", using: :btree

  create_table "reservations", force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.datetime "created_at", null: false
    t.datetime "ends_at"
    t.string "kind"
    t.integer "meal_id"
    t.string "name", limit: 24, null: false
    t.text "note"
    t.integer "reserver_id", null: false
    t.integer "resource_id", null: false
    t.integer "sponsor_id"
    t.datetime "starts_at"
    t.datetime "updated_at", null: false
  end

  add_index "reservations", ["cluster_id"], name: "index_reservations_on_cluster_id", using: :btree
  add_index "reservations", ["meal_id"], name: "index_reservations_on_meal_id", using: :btree
  add_index "reservations", ["reserver_id"], name: "index_reservations_on_reserver_id", using: :btree
  add_index "reservations", ["resource_id"], name: "index_reservations_on_resource_id", using: :btree
  add_index "reservations", ["sponsor_id"], name: "index_reservations_on_sponsor_id", using: :btree
  add_index "reservations", ["starts_at"], name: "index_reservations_on_starts_at", using: :btree

  create_table "resources", force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.integer "community_id", null: false
    t.datetime "created_at", null: false
    t.string "default_calendar_view", default: "week", null: false
    t.text "guidelines"
    t.boolean "hidden", default: false, null: false
    t.string "meal_abbrv", limit: 6
    t.string "name", limit: 24, null: false
    t.string "photo_content_type"
    t.string "photo_file_name"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at"
    t.datetime "updated_at", null: false
  end

  add_index "resources", ["cluster_id"], name: "index_resources_on_cluster_id", using: :btree
  add_index "resources", ["community_id", "name"], name: "index_resources_on_community_id_and_name", unique: true, using: :btree
  add_index "resources", ["community_id"], name: "index_resources_on_community_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at"
    t.string "name"
    t.integer "resource_id"
    t.string "resource_type"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "signups", force: :cascade do |t|
    t.integer "adult_meat", default: 0, null: false
    t.integer "adult_veg", default: 0, null: false
    t.integer "big_kid_meat", default: 0, null: false
    t.integer "big_kid_veg", default: 0, null: false
    t.integer "cluster_id", null: false
    t.text "comments"
    t.datetime "created_at", null: false
    t.integer "household_id", null: false
    t.integer "little_kid_meat", default: 0, null: false
    t.integer "little_kid_veg", default: 0, null: false
    t.integer "meal_id", null: false
    t.boolean "notified", default: false, null: false
    t.integer "senior_meat", default: 0, null: false
    t.integer "senior_veg", default: 0, null: false
    t.integer "teen_meat", default: 0, null: false
    t.integer "teen_veg", default: 0, null: false
    t.datetime "updated_at", null: false
  end

  add_index "signups", ["cluster_id"], name: "index_signups_on_cluster_id", using: :btree
  add_index "signups", ["household_id", "meal_id"], name: "index_signups_on_household_id_and_meal_id", unique: true, using: :btree
  add_index "signups", ["household_id"], name: "index_signups_on_household_id", using: :btree
  add_index "signups", ["meal_id"], name: "index_signups_on_meal_id", using: :btree
  add_index "signups", ["notified"], name: "index_signups_on_notified", using: :btree

  create_table "statements", force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "cluster_id", null: false
    t.datetime "created_at", null: false
    t.date "due_on"
    t.decimal "prev_balance", precision: 10, scale: 2, null: false
    t.date "prev_stmt_on"
    t.boolean "reminder_sent", default: false, null: false
    t.decimal "total_due", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
  end

  add_index "statements", ["account_id"], name: "index_statements_on_account_id", using: :btree
  add_index "statements", ["cluster_id"], name: "index_statements_on_cluster_id", using: :btree
  add_index "statements", ["created_at"], name: "index_statements_on_created_at", using: :btree
  add_index "statements", ["due_on"], name: "index_statements_on_due_on", using: :btree

  create_table "transactions", force: :cascade do |t|
    t.integer "account_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.integer "cluster_id", null: false
    t.string "code", limit: 16, null: false
    t.datetime "created_at", null: false
    t.string "description", limit: 255, null: false
    t.date "incurred_on", null: false
    t.integer "quantity"
    t.integer "statement_id"
    t.integer "statementable_id"
    t.string "statementable_type", limit: 32
    t.decimal "unit_price", precision: 10, scale: 2
    t.datetime "updated_at", null: false
  end

  add_index "transactions", ["account_id"], name: "index_transactions_on_account_id", using: :btree
  add_index "transactions", ["cluster_id"], name: "index_transactions_on_cluster_id", using: :btree
  add_index "transactions", ["code"], name: "index_transactions_on_code", using: :btree
  add_index "transactions", ["incurred_on"], name: "index_transactions_on_incurred_on", using: :btree
  add_index "transactions", ["statement_id"], name: "index_transactions_on_statement_id", using: :btree
  add_index "transactions", ["statementable_id", "statementable_type"], name: "index_transactions_on_statementable_id_and_statementable_type", using: :btree

  create_table "users", force: :cascade do |t|
    t.string "alternate_id"
    t.date "birthdate"
    t.string "calendar_token"
    t.boolean "child", default: false, null: false
    t.integer "cluster_id", null: false
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.inet "current_sign_in_ip"
    t.datetime "deactivated_at"
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.boolean "fake", default: false
    t.string "first_name", null: false
    t.string "google_email"
    t.string "home_phone"
    t.integer "household_id", null: false
    t.date "joined_on"
    t.string "last_name", null: false
    t.datetime "last_sign_in_at"
    t.inet "last_sign_in_ip"
    t.string "mobile_phone"
    t.string "photo_content_type"
    t.string "photo_file_name"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at"
    t.string "preferred_contact"
    t.jsonb "privacy_settings", default: {}, null: false
    t.string "provider"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "uid"
    t.datetime "updated_at", null: false
    t.string "work_phone"
  end

  add_index "users", ["alternate_id"], name: "index_users_on_alternate_id", using: :btree
  add_index "users", ["cluster_id"], name: "index_users_on_cluster_id", using: :btree
  add_index "users", ["deactivated_at"], name: "index_users_on_deactivated_at", using: :btree
  add_index "users", ["google_email"], name: "index_users_on_google_email", unique: true, using: :btree
  add_index "users", ["household_id"], name: "index_users_on_household_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  add_foreign_key "accounts", "clusters"
  add_foreign_key "accounts", "communities"
  add_foreign_key "accounts", "households"
  add_foreign_key "accounts", "statements", column: "last_statement_id"
  add_foreign_key "assignments", "clusters"
  add_foreign_key "assignments", "meals"
  add_foreign_key "assignments", "users"
  add_foreign_key "communities", "clusters"
  add_foreign_key "households", "clusters"
  add_foreign_key "households", "communities"
  add_foreign_key "invitations", "clusters"
  add_foreign_key "invitations", "communities"
  add_foreign_key "invitations", "meals"
  add_foreign_key "meals", "clusters"
  add_foreign_key "meals", "communities"
  add_foreign_key "meals", "users", column: "creator_id"
  add_foreign_key "meals_costs", "clusters"
  add_foreign_key "meals_costs", "meals"
  add_foreign_key "meals_formulas", "clusters"
  add_foreign_key "meals_formulas", "communities"
  add_foreign_key "people_emergency_contacts", "clusters"
  add_foreign_key "people_emergency_contacts", "households"
  add_foreign_key "people_guardianships", "clusters"
  add_foreign_key "people_vehicles", "clusters"
  add_foreign_key "people_vehicles", "households"
  add_foreign_key "reservation_guideline_inclusions", "clusters"
  add_foreign_key "reservation_guideline_inclusions", "reservation_shared_guidelines", column: "shared_guidelines_id"
  add_foreign_key "reservation_guideline_inclusions", "resources"
  add_foreign_key "reservation_protocolings", "clusters"
  add_foreign_key "reservation_protocolings", "reservation_protocols", column: "protocol_id"
  add_foreign_key "reservation_protocolings", "resources"
  add_foreign_key "reservation_protocols", "clusters"
  add_foreign_key "reservation_protocols", "communities"
  add_foreign_key "reservation_resourcings", "clusters"
  add_foreign_key "reservation_resourcings", "meals"
  add_foreign_key "reservation_resourcings", "resources"
  add_foreign_key "reservation_shared_guidelines", "clusters"
  add_foreign_key "reservation_shared_guidelines", "communities"
  add_foreign_key "reservations", "clusters"
  add_foreign_key "reservations", "meals"
  add_foreign_key "reservations", "resources"
  add_foreign_key "reservations", "users", column: "reserver_id"
  add_foreign_key "reservations", "users", column: "sponsor_id"
  add_foreign_key "resources", "clusters"
  add_foreign_key "resources", "communities"
  add_foreign_key "signups", "clusters"
  add_foreign_key "signups", "households"
  add_foreign_key "signups", "meals"
  add_foreign_key "statements", "accounts"
  add_foreign_key "statements", "clusters"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "clusters"
  add_foreign_key "transactions", "statements"
  add_foreign_key "users", "clusters"
  add_foreign_key "users", "households"
  add_foreign_key "users_roles", "roles"
  add_foreign_key "users_roles", "users"
end
