class NftFlipRecordsController < ApplicationController
  def index
    @page_index = 5
    @q = NftFlipRecord.includes(:nft).ransack(params[:q])
    @records = @q.result.order(sold_time: :desc).page(params[:page]).per(10)

    fliper_records = NftFlipRecord.today.group_by(&:fliper_address)
    @top_flipers = helpers.get_data(fliper_records, "top")
    @last_flipers = helpers.get_data(fliper_records, "last")

    collection_records = NftFlipRecord.today.group_by(&:slug)
    @top_collections = helpers.get_data(collection_records, "top")
    @last_collections = helpers.get_data(collection_records, "last")

    respond_to do |format|
      format.html
      format.js
    end
  end

  def fliper_detail
    @fliper_data = NftFlipRecord.where(fliper_address: params[:fliper_address])
    @rank = NftFlipRecord.all.group_by(&:fliper_address).sort_by{|k, v| v.sum(&:revenue)}.map{|k,v| k}.index(params[:fliper_address]) + 1
    @top_nfts = @fliper_data.group_by(&:slug).map{|k,v| [k, v.sum(&:revenue), v.sum(&:crypto_revenue), v.first.sold_coin]}.sort_by{|r| r[1]}.reverse.first(3)
    @flip_data_chart = PriceChartService.new(start_date: 7.days.ago.to_date, fliper_address: params[:fliper_address]).get_flip_data
    @flip_count_chart = PriceChartService.new(start_date: 7.days.ago.to_date, fliper_address: params[:fliper_address]).get_flip_count
  end

  def collection_detail
    @collection_data = NftFlipRecord.where(slug: params[:slug])
    @rank = NftFlipRecord.all.group_by(&:slug).sort_by{|k, v| v.sum(&:revenue)}.map{|k,v| k}.index(params[:slug]) + 1
    @top_flipers = @collection_data.group_by(&:fliper_address).map{|k,v| [k, v.sum(&:revenue), v.sum(&:crypto_revenue), v.first.sold_coin]}.sort_by{|r| r[1]}.reverse.first(3)
    @flip_data_chart = PriceChartService.new(start_date: 7.days.ago.to_date, slug: params[:slug]).get_flip_data
    @flip_count_chart = PriceChartService.new(start_date: 7.days.ago.to_date, slug: params[:slug]).get_flip_count
    @trade_data = PriceChartService.new(start_date: period_date(params[:trade_period]), slug: params[:slug]).get_trade_data
    @trade_records = NftTrade.joins(:nft).where(nft: {opensea_slug: params[:slug]}).order(trade_time: :desc).page(params[:trade_page]).per(10)
    @listing_items = NftListingItem.joins(:nft).where("nfts.opensea_slug = ? and listing_date > ?", params[:slug], Time.now - 2.hours).order(base_price: :asc).page(params[:listing_page]).per(10)

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
    @listing_items = NftListingItem.joins(:nft).where("nfts.opensea_slug = ? and listing_date > ?", params[:slug], Time.now - 2.hours).order(base_price: :asc).page(params[:listing_page]).per(10)
    respond_to do |format|
      format.js
    end
  end

  private
  def period_date(period)
    case period
    when "month" then Date.today.last_month.to_date
    when "week" then 7.days.ago.to_date
    else Date.today
    end
  end
end
