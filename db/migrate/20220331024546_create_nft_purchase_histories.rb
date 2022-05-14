class CreateNftPurchaseHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :nft_purchase_histories do |t|
      t.integer :nft_id
      t.integer :owner_id
      t.integer :amount
      t.date    :purchase_date

      t.timestamps
    end

    add_index :nft_purchase_histories, [:nft_id, :owner_id]
  end
end
