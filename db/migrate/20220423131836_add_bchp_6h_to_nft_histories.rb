class AddBchp6hToNftHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :nft_histories, :bchp_6h, :decimal
  end
end
