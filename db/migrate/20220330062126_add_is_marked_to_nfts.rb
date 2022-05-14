class AddIsMarkedToNfts < ActiveRecord::Migration[6.1]
  def change
    add_column :nfts, :is_marked, :boolean, default: false
  end
end
