class CreateNftHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :nft_histories do |t|
      t.integer :nft_id
      t.integer :sales
      t.decimal :floor_price
      t.decimal :volume
      t.date :event_date

      t.timestamps
    end

    add_index :nft_histories, :nft_id
  end
end
