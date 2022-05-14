class AddIndexToOwnerNfts < ActiveRecord::Migration[6.1]
  def change
    add_index :owner_nfts, :owner_id
    add_index :owner_nfts, :nft_id
    add_index :owner_nfts, :event_date
    add_index :owner_nfts, [:owner_id, :nft_id, :event_date]
  end
end
