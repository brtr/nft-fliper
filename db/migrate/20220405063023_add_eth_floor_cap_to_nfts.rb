class AddEthFloorCapToNfts < ActiveRecord::Migration[6.1]
  def change
    add_column :nfts, :eth_floor_cap, :decimal
  end
end
