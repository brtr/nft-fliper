class CreateNftSnapShots < ActiveRecord::Migration[6.1]
  def change
    create_table :nft_snap_shots do |t|
      t.date :event_date

      t.timestamps
    end

    add_index :nft_snap_shots, :event_date
  end
end
