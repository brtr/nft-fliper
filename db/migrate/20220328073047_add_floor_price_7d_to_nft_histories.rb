class AddFloorPrice7dToNftHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :nft_histories, :floor_price_7d, :decimal
  end
end
