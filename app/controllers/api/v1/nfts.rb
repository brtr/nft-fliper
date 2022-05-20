module API
  module V1
    class Nfts < Grape::API
      resource :nfts do
        desc 'Get all nfts'
        get do
          nfts = Nft.where.not(opensea_slug: nil).pluck(:opensea_slug)

          present :data, nfts, with: Grape::Presenters::Presenter
          present :result, true
          present :status, 200
        end
      end
    end
  end
end