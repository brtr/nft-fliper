class CreateNftFlipRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :nft_flip_records do |t|
      t.integer  :nft_id
      t.string   :slug
      t.string   :token_address
      t.string   :token_id
      t.string   :from_address
      t.string   :to_address
      t.string   :txid
      t.decimal  :price
      t.decimal  :cost
      t.decimal  :revenue
      t.decimal  :roi
      t.datetime :trade_time

      t.timestamps
    end

    add_index :nft_flip_records, :nft_id
    add_index :nft_flip_records, :slug
    add_index :nft_flip_records, :token_address
    add_index :nft_flip_records, [:nft_id, :token_id]
    add_index :nft_flip_records, :txid
    add_index :nft_flip_records, :trade_time
  end
end
