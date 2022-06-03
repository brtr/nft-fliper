class AddSubscriptionDateToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :subscription_date, :datetime
  end
end
