class CreateNftTransfers < ActiveRecord::Migration[6.1]
  def change
    create_table :nft_transfers do |t|
      t.integer  :nft_id
      t.string   :from_address
      t.string   :to_address
      t.string   :block_number
      t.string   :block_hash
      t.string   :token_id
      t.decimal  :value
      t.decimal  :amount
      t.datetime :block_timestamp

      t.timestamps
    end

    add_index :nft_transfers, :nft_id
  end
end
