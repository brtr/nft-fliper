class AddSyncTradesToNfts < ActiveRecord::Migration[6.1]
  def change
    add_column :nfts, :sync_trades, :boolean, default: false
    add_index :nfts, :sync_trades
  end
end
