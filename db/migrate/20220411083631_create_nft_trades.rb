class CreateNftTrades < ActiveRecord::Migration[6.1]
  def change
    create_table :nft_trades do |t|
      t.integer  :nft_id
      t.string   :buyer
      t.string   :seller
      t.string   :token_id
      t.decimal  :trade_price
      t.datetime :trade_time

      t.timestamps
    end

    add_index :nft_trades, :nft_id
  end
end
