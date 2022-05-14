class CreateAnalysisNftHolders < ActiveRecord::Migration[6.1]
  def change
    create_table :analysis_nft_holders do |t|
      t.string  :token_name
      t.string  :token_address
      t.string  :holder_address
      t.decimal :amount

      t.timestamps
    end

    add_index :analysis_nft_holders, :token_address
    add_index :analysis_nft_holders, :holder_address
    add_index :analysis_nft_holders, [:token_address, :holder_address], unique: true, name: :index_analysis_nft_holders_on_token_and_holder_address
  end
end
