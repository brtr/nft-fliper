class CreateUserTrades < ActiveRecord::Migration[6.1]
  def change
    create_table :user_trades do |t|
      t.integer  :user_address_id
      t.string   :collection
      t.string   :token_address
      t.string   :from_address
      t.string   :to_address
      t.string   :txid
      t.decimal  :price
      t.datetime :trade_time

      t.timestamps
    end

    add_index :user_trades, :user_address_id
    add_index :user_trades, :collection
    add_index :user_trades, :token_address
  end
end
