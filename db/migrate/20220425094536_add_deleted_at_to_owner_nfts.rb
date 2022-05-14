class AddDeletedAtToOwnerNfts < ActiveRecord::Migration[6.1]
  def change
    add_column :owner_nfts, :deleted_at, :datetime
    add_index :owner_nfts, :deleted_at
  end
end
