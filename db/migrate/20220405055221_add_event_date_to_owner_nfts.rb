class AddEventDateToOwnerNfts < ActiveRecord::Migration[6.1]
  def change
    add_column :owner_nfts, :event_date, :date
    add_index :owner_nfts, [:nft_id, :event_date]
  end
end
