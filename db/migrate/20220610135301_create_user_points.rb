class CreateUserPoints < ActiveRecord::Migration[6.1]
  def change
    create_table :user_points do |t|
      t.integer  :user_id
      t.integer  :points
      t.datetime :staking_time
      t.datetime :claim_time

      t.timestamps
    end

    add_index :user_points, :user_id
  end
end
