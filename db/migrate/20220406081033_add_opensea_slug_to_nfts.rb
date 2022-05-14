class AddOpenseaSlugToNfts < ActiveRecord::Migration[6.1]
  def change
    add_column :nfts, :opensea_slug, :string
  end
end
