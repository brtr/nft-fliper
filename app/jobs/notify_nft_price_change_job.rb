class NotifyNftPriceChangeJob < ApplicationJob
  queue_as :daily_job

  def perform
    result = NotifyPriceChangeNftsService.get_price_change_nfts

    result.map{|r| fall_price_blocks(r)}.each_slice(10).each do |r|
      puts r
      SlackService.send_notification(nil, r)
    end
  end

  def fall_price_blocks(data)
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*#{data[0]}* 在一周内价格跌破前低，上一次最低点为 #{data[1].round(3)}, 最新价格为 #{data[2].round(3)}, 下跌幅度为 #{(data[3] * 100).round(3)}%"
      }
    }
  end
end