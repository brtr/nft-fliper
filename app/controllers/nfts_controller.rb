class NftsController < ApplicationController
  before_action :get_nft, only: [:edit, :update, :sync_data, :bch_list]

  def index
    @page_index = 0
    @page = params[:page].to_i || 1
    sort_by = params[:sort_by] || "eth_volume_24h"
    @sort = params[:sort] == "desc" ? "asc" : "desc"
    @q = NftsView.includes(:nft).ransack(params[:q])
    nfts = @q.result
    @nfts = nfts.where("eth_volume_24h >= ?", 100).order("#{sort_by} #{@sort}").page(@page).per(50)
  end

  def show
    date = Date.yesterday
    @nft = NftsView.find_by slug: params[:id]
    latest_histories = @nft.target_nft_owner_histories.last_day
    @purchase_24h = latest_histories.purchase.take.data rescue {}
    @purchase_7d = @nft.target_nft_owner_histories.purchase.where(event_date: [date - 7.days..date]).map(&:data)
    @price_data = PriceChartService.new(start_date: period_date(params[:price_period]), nft_id: @nft.nft_id).get_price_data
    @holding_data = PriceChartService.new(start_date: period_date(params[:holding_period]), nft_id: @nft.nft_id).get_holding_data
    @purchase_data = PriceChartService.new(start_date: period_date(params[:purchase_period]), nft_id: @nft.nft_id).get_purchase_data
    @trade_data = PriceChartService.new(start_date: period_date(params[:trade_period]), nft_id: @nft.nft_id).get_trade_data
  end

  def new
    @nft = Nft.new
  end

  def create
    nft = Nft.new(nft_params)
    if nft.address.match(/^0x[a-fA-F0-9]{40}$/)
      nft.user_id = session[:user_id]
      nft.save
      redirect_to user_nfts_path(nft.user_id), notice: "Add NFT successful!"
    else
      flash[:alert] = "Invalid address!"
      @nft = Nft.new

      render :new
    end
  end

  def edit
  end

  def update
    if @nft.update(nft_params)
      flash[:notice] = "Update NFT successful!"
    else
      flash[:alert] = @nft.errors.full_messages.join(', ')
    end

    redirect_to user_nfts_path(@nft.user_id)
  end

  def sync_data
    FetchSingleNftDataJob.perform_later(@nft.id)

    redirect_to user_nfts_path(@nft.user_id), notice: "Data is syncing, please refresh the page later!"
  end

  def bch_list
    @data = @nft.target_nft_owner_histories.last_day.holding.take.data
    @result = @data[:data].sort_by{|k, v| v[:owners_ratio]}.reverse rescue {}
  end

  def purchase_rank
    @page_index = 1
    data = NftPurchaseHistory.without_target_nfts.last_day.group(:nft_id).count.map{|k, v| [k, v]}.sort_by{|k, v| v}.reverse.first(10).to_h
    @nfts = NftsView.includes(:nft_trades).find(data.keys)
  end

  def holding_rank
    @page_index = 2
    snap_shot = HoldingRankSnapShot.last
    @nfts = snap_shot.holding_rank_snap_shot_views
  end

  private
  def get_nft
    @nft = Nft.find_by id: params[:id]
  end

  def period_date(period)
    case period
    when "month" then Date.today.last_month.to_date
    when "year" then Date.today.last_year.to_date
    else 7.days.ago.to_date
    end
  end

  def nft_params
    params.require(:nft).permit(:name, :slug, :address, :opensea_slug, :opensea_url, :logo, :total_supply)
  end
end
