class AddImageToNftFlipRecords < ActiveRecord::Migration[6.1]
  def change
    add_column :nft_flip_records, :image, :string
  end
end
