class AddBchpAndMedianToNftHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :nft_histories, :bchp, :decimal
    add_column :nft_histories, :median, :decimal
  end
end
