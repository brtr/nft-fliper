class AddEthVolumeRankAndEthFloorPriceAndEthVolumeToNftHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :nft_histories, :eth_volume_rank, :integer
    add_column :nft_histories, :eth_floor_price, :decimal
    add_column :nft_histories, :eth_volume, :decimal
  end
end
