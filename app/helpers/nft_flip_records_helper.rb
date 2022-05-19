module NftFlipRecordsHelper
  def chain_logo_path(nft)
    nft.chain_id == 1 ? 'eth.png' : 'solana.png'
  end
end
