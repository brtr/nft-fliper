require 'open-uri'
require 'csv'

class AnalysisDataService
  class << self
    def fetch_token_holders(name, address)
      csv_text = File.read("#{name}.csv")
      csv = CSV.parse(csv_text, :headers => true, :encoding => "ISO-8859-1")
      csv.each do |row|
        a = AnalysisTokenHolder.where(token_address: address, holder_address: row["HolderAddress"]).first_or_create
        a.update(token_name: name, amount: row["Balance"].to_f)
      end
    end

    def fetch_nft_holders(address, cursor=nil)
      return unless address
      begin
        url = "https://deep-index.moralis.io/api/v2/nft/#{address}/owners?chain=eth&format=decimal"
        url += "&cursor=#{cursor}" if cursor
        response = URI.open(url, {"X-API-Key" => ENV["MORALIS_API_KEY"]}).read
        if response
          data = JSON.parse(response)
          name = data["result"][0]["name"] rescue ''
          result = data["result"].group_by{|x| x["owner_of"]}.inject({}){|sum, x| sum.merge({x[0] => x[1].map{|y| y["token_id"]}})}
          result.each do |add, token_ids|
            a = AnalysisNftHolder.where(token_address: address, holder_address: add).first_or_create
            a.update(token_name: name, amount: token_ids.size)
          end
  
          sleep 1
          fetch_nft_holders(address, data["cursor"]) if data["cursor"].present?
        end
      rescue => e
        FetchDataLog.create(fetch_type: mode, source: "Fetch nft holders", url: url, error_msgs: e, event_time: DateTime.now)
        puts "Fetch moralis Error: #{address} can't fetch nft holders"
      end
    end
  end
end