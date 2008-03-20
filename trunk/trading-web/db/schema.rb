# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 18) do

  create_table "account_regulation_types", :force => true do |t|
    t.string "name", :limit => 20, :null => false
  end

  add_index "account_regulation_types", ["name"], :name => "index_account_regulation_types_on_name", :unique => true

  create_table "account_types", :force => true do |t|
    t.integer "parent_id"
    t.string  "account_number", :limit => 80, :null => false
    t.string  "bg_desc",                      :null => false
    t.string  "en_desc",                      :null => false
  end

  add_index "account_types", ["account_number"], :name => "index_account_types_on_account_number", :unique => true
  add_index "account_types", ["parent_id"], :name => "parent_id"

  create_table "companies", :force => true do |t|
    t.integer  "type_id",                                    :null => false
    t.string   "name",         :limit => 160,                :null => false
    t.integer  "bul_stat",                                   :null => false
    t.string   "stock_symbol", :limit => 8
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "lock_version",                :default => 0, :null => false
  end

  add_index "companies", ["name"], :name => "index_companies_on_name", :unique => true
  add_index "companies", ["bul_stat"], :name => "index_companies_on_bul_stat", :unique => true
  add_index "companies", ["type_id"], :name => "type_id"

  create_table "company_backgrounds", :force => true do |t|
    t.integer  "company_id",                                :null => false
    t.string   "city"
    t.integer  "tax_no",       :limit => 20
    t.string   "branch"
    t.text     "activity"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "lock_version",               :default => 0, :null => false
  end

  add_index "company_backgrounds", ["company_id"], :name => "company_id"

  create_table "company_financials", :force => true do |t|
    t.integer  "company_id",                                     :null => false
    t.integer  "capital",           :limit => 20
    t.integer  "nominal"
    t.integer  "profit",            :limit => 20
    t.date     "profit_year"
    t.integer  "net_sales",         :limit => 20
    t.date     "net_sales_year"
    t.integer  "fixed_assets",      :limit => 20
    t.date     "fixed_assets_year"
    t.string   "currency",          :limit => 5
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.integer  "lock_version",                    :default => 0, :null => false
  end

  add_index "company_financials", ["company_id"], :name => "company_id"

  create_table "company_types", :force => true do |t|
    t.string "name", :limit => 20, :null => false
  end

  add_index "company_types", ["name"], :name => "index_company_types_on_name", :unique => true

  create_table "feedbacks", :force => true do |t|
    t.string   "email",        :limit => 68,                 :null => false
    t.string   "category",     :limit => 50,                 :null => false
    t.string   "subject",      :limit => 256,                :null => false
    t.text     "description",                                :null => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "lock_version",                :default => 0, :null => false
  end

  create_table "portfolio_withholdings", :force => true do |t|
    t.integer "portfolio_id",                           :null => false
    t.integer "trading_market_id",                      :null => false
    t.integer "transaction_type_id",                    :null => false
    t.integer "shares",                                 :null => false
    t.date    "date",                                   :null => false
    t.integer "price",               :default => 0
    t.string  "currency",            :default => "BGN"
    t.text    "pitch"
  end

  add_index "portfolio_withholdings", ["portfolio_id"], :name => "portfolio_id"
  add_index "portfolio_withholdings", ["trading_market_id"], :name => "trading_market_id"
  add_index "portfolio_withholdings", ["transaction_type_id"], :name => "transaction_type_id"

  create_table "portfolios", :force => true do |t|
    t.integer  "user_id",                                      :null => false
    t.integer  "amount",                    :default => 0,     :null => false
    t.string   "currency",     :limit => 5, :default => "BGN", :null => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.integer  "lock_version",              :default => 0,     :null => false
  end

  add_index "portfolios", ["user_id"], :name => "user_id"

  create_table "statement_amounts", :force => true do |t|
    t.integer  "account_type_id",                              :null => false
    t.integer  "statement_id",                                 :null => false
    t.integer  "amount",          :limit => 20,                :null => false
    t.string   "currency",        :limit => 5,                 :null => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.integer  "lock_version",                  :default => 0, :null => false
  end

  add_index "statement_amounts", ["account_type_id"], :name => "account_type_id"
  add_index "statement_amounts", ["statement_id"], :name => "statement_id"

  create_table "statement_types", :force => true do |t|
    t.string "name", :limit => 20, :null => false
  end

  add_index "statement_types", ["name"], :name => "index_statement_types_on_name", :unique => true

  create_table "statements", :force => true do |t|
    t.integer  "company_id",                                :null => false
    t.integer  "statement_type_id",                         :null => false
    t.integer  "account_regulation_type_id",                :null => false
    t.date     "regulatory_date",                           :null => false
    t.boolean  "consolidated",                              :null => false
    t.boolean  "audited",                                   :null => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "lock_version",               :default => 0, :null => false
  end

  add_index "statements", ["company_id"], :name => "company_id"
  add_index "statements", ["statement_type_id"], :name => "statement_type_id"
  add_index "statements", ["account_regulation_type_id"], :name => "account_regulation_type_id"

  create_table "stock_quotes", :force => true do |t|
    t.integer  "trading_market_id",                             :null => false
    t.datetime "timepoint",                                     :null => false
    t.integer  "volume"
    t.integer  "price_avrg"
    t.integer  "price",                                         :null => false
    t.string   "currency",          :limit => 5,                :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.integer  "lock_version",                   :default => 0, :null => false
  end

  add_index "stock_quotes", ["trading_market_id"], :name => "trading_market_id"

  create_table "system_settings", :force => true do |t|
    t.string   "name",                        :null => false
    t.text     "value",                       :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  add_index "system_settings", ["name"], :name => "index_system_settings_on_name", :unique => true

  create_table "trading_markets", :force => true do |t|
    t.integer  "company_id",                                            :null => false
    t.string   "market_name",          :limit => 80,                    :null => false
    t.string   "stock_symbol",         :limit => 8,                     :null => false
    t.integer  "last_traded_price"
    t.datetime "last_traded_date"
    t.integer  "prev_close"
    t.integer  "price_high"
    t.integer  "price_low"
    t.integer  "price_avrg"
    t.integer  "price_change",                       :default => 0,     :null => false
    t.float    "price_change_percent",               :default => 0.0,   :null => false
    t.string   "currency",             :limit => 5
    t.integer  "stock_volume",                       :default => 0,     :null => false
    t.integer  "nominal",                            :default => 0,     :null => false
    t.integer  "market_cap",           :limit => 20, :default => 0,     :null => false
    t.string   "nominal_currency",                   :default => "BGN", :null => false
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.integer  "lock_version",                       :default => 0,     :null => false
  end

  add_index "trading_markets", ["stock_symbol"], :name => "index_trading_markets_on_stock_symbol", :unique => true
  add_index "trading_markets", ["company_id"], :name => "company_id"

  create_table "transaction_types", :force => true do |t|
    t.string "name", :limit => 5,  :null => false
    t.string "desc", :limit => 30, :null => false
  end

  add_index "transaction_types", ["name"], :name => "index_transaction_types_on_name", :unique => true

  create_table "users", :force => true do |t|
    t.string   "login",         :limit => 80
    t.string   "cryptpassword", :limit => 40
    t.string   "validkey",      :limit => 40
    t.string   "email",         :limit => 100
    t.string   "newemail",      :limit => 100
    t.string   "ipaddr"
    t.integer  "confirmed"
    t.string   "domains",       :limit => 100
    t.string   "image",         :limit => 100
    t.string   "firstname",     :limit => 100
    t.string   "lastname",      :limit => 100
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.integer  "lock_version",                 :default => 0, :null => false
  end

  add_foreign_key "account_types", ["parent_id"], "account_types", ["id"], :name => "account_types_ibfk_1"

  add_foreign_key "companies", ["type_id"], "company_types", ["id"], :name => "companies_ibfk_1"

  add_foreign_key "company_backgrounds", ["company_id"], "companies", ["id"], :name => "company_backgrounds_ibfk_1"

  add_foreign_key "company_financials", ["company_id"], "companies", ["id"], :name => "company_financials_ibfk_1"

  add_foreign_key "portfolio_withholdings", ["portfolio_id"], "portfolios", ["id"], :name => "portfolio_withholdings_ibfk_1"
  add_foreign_key "portfolio_withholdings", ["trading_market_id"], "trading_markets", ["id"], :name => "portfolio_withholdings_ibfk_2"
  add_foreign_key "portfolio_withholdings", ["transaction_type_id"], "transaction_types", ["id"], :name => "portfolio_withholdings_ibfk_3"

  add_foreign_key "portfolios", ["user_id"], "users", ["id"], :name => "portfolios_ibfk_1"

  add_foreign_key "statement_amounts", ["account_type_id"], "account_types", ["id"], :name => "statement_amounts_ibfk_1"
  add_foreign_key "statement_amounts", ["statement_id"], "statements", ["id"], :name => "statement_amounts_ibfk_2"

  add_foreign_key "statements", ["company_id"], "companies", ["id"], :name => "statements_ibfk_1"
  add_foreign_key "statements", ["statement_type_id"], "statement_types", ["id"], :name => "statements_ibfk_2"
  add_foreign_key "statements", ["account_regulation_type_id"], "account_regulation_types", ["id"], :name => "statements_ibfk_3"

  add_foreign_key "stock_quotes", ["trading_market_id"], "trading_markets", ["id"], :name => "stock_quotes_ibfk_1"

  add_foreign_key "trading_markets", ["company_id"], "companies", ["id"], :name => "trading_markets_ibfk_1"

end
