class NftSnapShotsController < ApplicationController
  def index
    @page_index = 5
    infos = NftSnapShot.pluck(:id, :event_date)
    @results = split_event_dates(infos)
  end

  def show
    @info = NftSnapShot.find_by(id: params[:id])
    @page = params[:page].to_i || 1
    sort_by = params[:sort_by] || "eth_volume_24h"
    @sort = params[:sort] == "desc" ? "asc" : "desc"
    @q = @info.nft_snap_shot_views.ransack(params[:q])
    nfts = @q.result
    @nfts = nfts.where("eth_volume_24h >= ?", 100).order("#{sort_by} #{@sort}").page(@page).per(50)
  end

  private
  def split_event_dates(infos)
    date_records = []

    years = infos.map {|k| k[1].year}.uniq.sort
    months = infos.map {|k| k[1].month}.uniq.sort

    years.each do |y|
      monthes_array = []
      months.each do |m|
        set_month = m.to_i >= 10 ? m : "0#{m}"
        records = infos.select {|k| k[1].to_s.include?("#{y}-#{set_month}")}
        days = records.map {|k| {id: k[0], day: k[1].day}}.sort_by { |k| k[:day] }
        if days.present?
          monthes_array.push({
            month: m,
            dates: days
          })
        end
      end
      date_records.push({
        year: y,
        monthes: monthes_array
       })
    end

    date_records
  end
end
