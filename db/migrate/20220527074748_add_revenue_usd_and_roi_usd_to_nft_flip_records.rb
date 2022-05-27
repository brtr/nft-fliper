class AddRevenueUsdAndRoiUsdToNftFlipRecords < ActiveRecord::Migration[6.1]
  def change
    add_column :nft_flip_records, :revenue_usd, :decimal
    add_column :nft_flip_records, :roi_usd, :decimal
  end
end
