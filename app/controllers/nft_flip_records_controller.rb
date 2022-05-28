class NftFlipRecordsController < ApplicationController
  before_action :get_data, except: [:check_new_records, :get_new_records, :refresh_listings, :search_collection, :live_view]

  def index
    @page_index = 1
    @records = @data.where("sold > bought").order(sold_time: :desc).first(10)

    collection_records = @data.today.group_by(&:slug)
    @top_collections = helpers.get_data(collection_records, "profit", 15, "rate")
    @top_collection = @top_collections.first

    respond_to do |format|
      format.html
      format.js
    end
  end

  def fliper_analytics
    @fliper_data = @data.where(fliper_address: params[:fliper_address])
    @rank_data = NftFlipRecord.get_rank_data(fliper_address: params[:fliper_address])
    @top_nfts = @fliper_data.group_by(&:slug).map{|k,v| [k, v.sum(&:revenue), v.first.sold_coin, helpers.get_successful_rate(v)]}.sort_by{|r| r[4]}.reverse.first(3)
    @flip_data_chart = PriceChartService.new(start_at: Time.now - 1.week, fliper_address: params[:fliper_address]).get_flip_data
    @flip_count_chart = PriceChartService.new(start_at: Time.now - 1.week, fliper_address: params[:fliper_address]).get_flip_count
    @records = @fliper_data.order(sold_time: :desc).page(params[:fliper_page]).per(20)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def nft_analytics
    @collection_data = @data.where(slug: params[:slug])
    @rank_data = NftFlipRecord.get_rank_data(slug: params[:slug])
    @top_flipers = @collection_data.group_by(&:fliper_address).map{|k,v| [k, v.sum(&:revenue), v.first.sold_coin, helpers.get_successful_rate(v)]}.sort_by{|r| r[4]}.reverse.first(3)
    @flip_data_chart = PriceChartService.new(start_at: Time.now - 1.week, slug: params[:slug]).get_flip_data
    @flip_count_chart = PriceChartService.new(start_at: Time.now - 1.week, slug: params[:slug]).get_flip_count
    @records = @collection_data.order(sold_time: :desc).page(params[:fliper_page]).per(20)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def live_view
    @trade_data = PriceChartService.new(start_at: period_date(params[:trade_period]), slug: params[:slug]).get_trade_data
    @trade_records = NftTrade.joins(:nft).where(nft: {opensea_slug: params[:slug]}).order(trade_time: :desc).page(params[:trade_page]).per(10)
    @listing_items = fetch_listing_data(params[:slug])

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

    fliper_records = @data.where(sold_time: [period_date(params[:period])..Time.now]).group_by(&:fliper_address)
    @top_flipers = helpers.get_data(fliper_records, "profit")
    @last_flipers = helpers.get_data(fliper_records, "loss")

    collection_records = @data.where(sold_time: [period_date(params[:period])..Time.now]).group_by(&:slug)
    @top_collections = helpers.get_data(collection_records, "profit")
    @last_collections = helpers.get_data(collection_records, "loss")
  end

  def flip_flow
    @page_index = 3
    @q = @data.ransack(params[:q])
    @records = @q.result.order(sold_time: :desc).page(params[:fliper_page]).per(50)
  end

  private
  def period_date(period)
    case period
    when "hour" then Time.now - 1.hour
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

  def get_data
    @data = NftFlipRecord.includes(:nft).where("gap < ? or revenue > ?", 86400, 2)
  end
end
