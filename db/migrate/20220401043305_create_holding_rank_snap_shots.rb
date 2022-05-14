class CreateHoldingRankSnapShots < ActiveRecord::Migration[6.1]
  def change
    create_table :holding_rank_snap_shots do |t|
      t.date :event_date

      t.timestamps
    end

    add_index :holding_rank_snap_shots, :event_date
  end
end
