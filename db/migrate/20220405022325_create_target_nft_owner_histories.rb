class CreateTargetNftOwnerHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :target_nft_owner_histories do |t|
      t.integer :nft_id
      t.integer :n_type
      t.string  :data
      t.date    :event_date

      t.timestamps
    end

    add_index :target_nft_owner_histories, :nft_id
    add_index :target_nft_owner_histories, [:nft_id, :event_date, :n_type], unique: true, name: :index_target_nft_owner_histories_on_nft_id_event_date_and_type
  end
end
