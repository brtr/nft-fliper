class AddBchp12hToNftHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :nft_histories, :bchp_12h, :decimal
  end
end
