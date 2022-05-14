class CreateFetchDataLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :fetch_data_logs do |t|
      t.integer  :fetch_type
      t.string   :source
      t.string   :url
      t.string   :error_msgs
      t.datetime :event_time

      t.timestamps
    end
  end
end
