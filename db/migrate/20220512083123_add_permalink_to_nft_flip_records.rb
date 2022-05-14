class AddPermalinkToNftFlipRecords < ActiveRecord::Migration[6.1]
  def change
    add_column :nft_flip_records, :permalink, :string
  end
end
