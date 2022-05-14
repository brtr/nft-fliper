class CreateOwnerNfts < ActiveRecord::Migration[6.1]
  def change
    create_table :owner_nfts do |t|
      t.integer :owner_id
      t.integer :nft_id
      t.integer :amount
      t.string  :token_ids

      t.timestamps
    end

    add_index :owner_nfts, [:owner_id, :nft_id]
  end
end
