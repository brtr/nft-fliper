class AddColumnsToNftFlipRecords < ActiveRecord::Migration[6.1]
  def change
    remove_column :nft_flip_records, :trade_time
    add_column :nft_flip_records, :fliper_address, :string
    add_column :nft_flip_records, :bought_coin, :string
    add_column :nft_flip_records, :sold_coin, :string
    add_column :nft_flip_records, :cost_usd, :decimal
    add_column :nft_flip_records, :price_usd, :decimal
    add_column :nft_flip_records, :gap, :integer
    add_column :nft_flip_records, :sold_time, :datetime
    add_column :nft_flip_records, :bought_time, :datetime

    add_index :nft_flip_records, :fliper_address
    add_index :nft_flip_records, :bought_coin
    add_index :nft_flip_records, :sold_coin
  end
end
