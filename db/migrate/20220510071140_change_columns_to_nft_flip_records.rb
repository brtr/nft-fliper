class ChangeColumnsToNftFlipRecords < ActiveRecord::Migration[6.1]
  def change
    rename_column :nft_flip_records, :cost, :bought
    rename_column :nft_flip_records, :cost_usd, :bought_usd
    rename_column :nft_flip_records, :price, :sold
    rename_column :nft_flip_records, :price_usd, :sold_usd
  end
end
