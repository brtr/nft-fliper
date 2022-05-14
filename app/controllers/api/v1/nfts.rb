module API
  module V1
    class Nfts < Grape::API
      resource :nfts do
        desc 'Get target NFT price data and owners data'
        get :data do
          nft = Nft.where(opensea_slug: params[:slug]).take
          price_data = PriceChartService.new(start_date: 7.days.ago.to_date, nft_id: nft.id).get_price_data rescue {}
          owner_data = nft.target_nft_owner_histories.last_day.holding.take.data
          bch_count = owner_data[:bch_count].to_f rescue 0
          ratio = bch_count / owner_data[:total_count].to_f rescue 0
          data = {
            price_data: price_data,
            bch_count: bch_count.to_i,
            bchp: ratio.round(2)
          }

          present :result, true
          present :data, data, with: Grape::Presenters::Presenter
          present :status, 200
        end

        desc 'Get bchp from user address'
        get :bchp do
          address = NftOwnerService.get_address(params[:address])
          total_nfts = OwnerNft.joins(:owner).where(owner: {address: address}).pluck(:nft_id).uniq
          bch = Nft.where(id: total_nfts, is_marked: true).count
          total = total_nfts.count
          ratio = total == 0 ? 0 : bch / total.to_f

          data = {
            total: total_nfts.count,
            bchp: ratio.round(2)
          }

          present :result, true
          present :data, data, with: Grape::Presenters::Presenter
          present :status, 200
        end
      end
    end
  end
end