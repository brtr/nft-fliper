class AddTotalVolumeToNfts < ActiveRecord::Migration[6.1]
  def change
    add_column :nfts, :total_volume, :decimal
  end
end
