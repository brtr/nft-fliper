class HomeController < ApplicationController
  def fliper_pass_nft
    @page_index = 4
  end

  def not_permitted
    render json: {message: helpers.error_msgs(params[:error_code])}
  end

  def staking
    @page_index = 5
  end

  def mint
    @page_index = 6
  end
end
