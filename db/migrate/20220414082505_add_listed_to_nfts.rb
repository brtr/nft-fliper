class AddListedToNfts < ActiveRecord::Migration[6.1]
  def change
    add_column :nfts, :listed, :decimal
  end
end
