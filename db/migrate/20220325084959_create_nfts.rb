class CreateNfts < ActiveRecord::Migration[6.1]
  def change
    create_table :nfts do |t|
      t.integer :chain_id
      t.string  :name
      t.string  :symbol
      t.string  :slug
      t.string  :website
      t.string  :opensea_url
      t.string  :address
      t.string  :logo
      t.decimal :total_supply
      t.decimal :floor_cap
      t.decimal :listed_ratio
      t.decimal :variation

      t.timestamps
    end
  end
end
