class UsersController < ApplicationController
  def login
    user = User.where(address: params[:address]).first_or_create
    session[:user_id] = user.id

    render json: {success: true}
  end

  def logout
    session[:user_id] = nil if session[:user_id]

    render json: {success: true}
  end

  def nfts
    user = User.find_by id: session[:user_id]
    if user
      sort_by = params[:sort_by] || "eth_volume_24h"
      @sort = params[:sort] == "desc" ? "asc" : "desc"
      nfts = user.nfts_views
      @nfts = nfts.sort_by{|n| n.send(sort_by).send(:to_f)}
      @nfts = @nfts.reverse if @sort == "asc"
    else
      redirect_to root_path
    end
  end
end
