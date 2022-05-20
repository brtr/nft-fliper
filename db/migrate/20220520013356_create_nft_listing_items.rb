class CreateNftListingItems < ActiveRecord::Migration[6.1]
  def change
    create_table :nft_listing_items do |t|
      t.integer  :nft_id
      t.integer  :status, default: 0
      t.string   :token_id
      t.string   :permalink
      t.decimal  :base_price
      t.datetime :listing_date

      t.timestamps
    end

    add_index :nft_listing_items, :nft_id
    add_index :nft_listing_items, :status
    add_index :nft_listing_items, :token_id
  end
end
