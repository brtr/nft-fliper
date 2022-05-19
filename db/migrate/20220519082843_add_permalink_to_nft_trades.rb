class AddPermalinkToNftTrades < ActiveRecord::Migration[6.1]
  def change
    add_column :nft_trades, :permalink, :string
  end
end
