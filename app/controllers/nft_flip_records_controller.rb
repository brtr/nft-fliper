class NftFlipRecordsController < ApplicationController
  def index
    @page_index = 1
    records = NftFlipRecord.includes(:nft)
    @records = records.where("sold > bought").order(sold_time: :desc).first(10)

    collection_records = records.today.group_by(&:slug)
    @top_collections = helpers.get_data(collection_records, "top", 15)
    @top_collection = @top_collections.first

    respond_to do |format|
      format.html
      format.js
    end
  end

  def fliper_detail
    records = NftFlipRecord.includes(:nft)
    @fliper_data = records.where(fliper_address: params[:fliper_address])
    @rank = records.group_by(&:fliper_address).sort_by{|k, v| v.sum(&:revenue)}.map{|k,v| k}.index(params[:fliper_address]) + 1 rescue 0
    @top_nfts = @fliper_data.group_by(&:slug).map{|k,v| [k, v.sum(&:revenue_usd), v.sum(&:revenue), v.first.sold_coin]}.sort_by{|r| r[1]}.reverse.first(3)
    @flip_data_chart = PriceChartService.new(start_at: Time.now - 1.week, fliper_address: params[:fliper_address]).get_flip_data
    @flip_count_chart = PriceChartService.new(start_at: Time.now - 1.week, fliper_address: params[:fliper_address]).get_flip_count
    @records = @fliper_data.page(params[:fliper_page]).per(20)
  end

  def collection_detail
    records = NftFlipRecord.includes(:nft)
    @collection_data = records.where(slug: params[:slug])
    @rank = records.group_by(&:slug).sort_by{|k, v| v.sum(&:revenue)}.map{|k,v| k}.index(params[:slug]) + 1 rescue 0
    @top_flipers = @collection_data.group_by(&:fliper_address).map{|k,v| [k, v.sum(&:revenue_usd), v.sum(&:revenue), v.first.sold_coin]}.sort_by{|r| r[1]}.reverse.first(3)
    @flip_data_chart = PriceChartService.new(start_at: Time.now - 1.week, slug: params[:slug]).get_flip_data
    @flip_count_chart = PriceChartService.new(start_at: Time.now - 1.week, slug: params[:slug]).get_flip_count
    @trade_data = PriceChartService.new(start_at: period_date(params[:trade_period]), slug: params[:slug]).get_trade_data
    @trade_records = NftTrade.joins(:nft).where(nft: {opensea_slug: params[:slug]}).order(trade_time: :desc).page(params[:trade_page]).per(10)
    @listing_items = fetch_listing_data(params[:slug])
    @records = @collection_data.page(params[:fliper_page]).per(20)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def check_new_records
    last_id = NftFlipRecord.maximum(:id)

    render json: {last_id: last_id}
  end

  def get_new_records
    last = NftFlipRecord.maximum(:id)
    @q = NftFlipRecord.includes(:nft).ransack(params[:q])
    @records = @q.result.where(id: [params[:id].to_i..last]).order(sold_time: :desc)
  end

  def refresh_listings
    @listing_items = fetch_listing_data(params[:slug])
    respond_to do |format|
      format.js
    end
  end

  def search_collection
    result = Nft.ransack(opensea_slug_cont: params[:q]).result

    render json: result.map{|nft| {id: nft.id, text: nft.opensea_slug}}
  end

  def trending
    @page_index = 2

    records = NftFlipRecord.includes(:nft)
    fliper_records = records.where(sold_time: [period_date(params[:period])..Time.now]).group_by(&:fliper_address)
    @top_flipers = helpers.get_data(fliper_records, "top")
    @last_flipers = helpers.get_data(fliper_records, "last")

    collection_records = records.where(sold_time: [period_date(params[:period])..Time.now]).group_by(&:slug)
    @top_collections = helpers.get_data(collection_records, "top")
    @last_collections = helpers.get_data(collection_records, "last")
  end

  def flip_flow
    @page_index = 3
    @q = NftFlipRecord.includes(:nft).ransack(params[:q])
    @records = @q.result.order(sold_time: :desc).page(params[:fliper_page]).per(50)
  end

  private
  def period_date(period)
    case period
    when "month" then Time.now - 1.month
    when "week" then Time.now - 1.week
    else Time.now - 1.day
    end
  end

  def fetch_listing_data(slug)
    nft = Nft.find_by(opensea_slug: slug)
    if nft.chain_id == 1
      nft.nft_listing_items.where("listing_date > ?", Time.now - 2.hours).order(base_price: :asc)
          .page(params[:listing_page]).per(10).map{|item| item.as_json}
    else
      records = JSON.parse($redis.get "#{nft.slug}_listings") rescue []
      records = records.map do |record|
        {
          nft_id: nft.id,
          token_id: record["name"].split("#").last,
          base_price: record["price"],
          permalink: "https://solanart.io/nft/#{record['token_add']}",
          listing_date: nil
        }.as_json
      end

      Kaminari.paginate_array(records).page(params[:listing_page]).per(10)
    end
  end
end
