require "rails_helper"

RSpec.describe NftHistoryService, type: :service do
  let(:nft) { create(:nft) }
  let(:record) { create(:nft_flip_record, nft: nft) }
  let(:data) {
    {
      next: nil,
      previous: nil,
      asset_events: [
        {
          asset: {
            id: 524819687,
            num_sales: 2,
            image_url: "https://lh3.googleusercontent.com/VhTN9yJfcrXNUvTiXPDS0d91rJk6lSUTGuqcB12gbzgKhD9Y4o6YT2OkCreEXRssbrCCsrGzlxF8jWnsQ0KCv_28R4EpxVyXaxno3A",
            name: "VoxelVeryLongAnimals #68",
            asset_contract: {
              address: "0x495f947276749ce646f68ac8c248420045cb7b5e",
              asset_contract_type: "semi-fungible",
              created_date: "2020-12-02T17:40:53.232025",
              name: "OpenSea Collection",
              schema_name: "ERC721",
              symbol: "OPENSTORE",
              description: "",
              image_url: "https://lh3.googleusercontent.com/HMeSm6mM47Wkap8it2rXBbyCIF0wiAXpamQJQidiCmF4wL-zL5sS2UXZuH6jm65kpXy2XwaS1T9gkD7x2UbB34qlwTLMTBHmyqx5qA=s120",
            },
            permalink: "https://opensea.io/assets/ethereum/0x495f947276749ce646f68ac8c248420045cb7b5e/45842623875473506218454663566956654960606928855917337691641461616325697732609",
            collection: {
              banner_image_url: "https://lh3.googleusercontent.com/5X010ZPITmEa7zK4bX4PmndkVOyE9oBbRBYKNylN1ryG2CUqfcTclMgif64cD0xf1wQGMFULV7joNX680h48ogdYu_1pEe4WTNRFBw=s2500",
              name: "VoxelVeryLongAnimals",
              payout_address: "0x655a01706cf1bd04df0f8761febb1e9cfc1bc085",
              slug: "voxelverylonganimals",
            },
            decimals: nil,
            token_metadata: nil,
            is_nsfw: false,
            owner: {
              user: {
                username: "NullAddress"
              },
              address: "0x0000000000000000000000000000000000000000",
              config: ""
            },
            token_id: "45842623875473506218454663566956654960606928855917337691641461616325697732609"
          },
          asset_bundle: nil,
          event_type: "successful",
          event_timestamp: "2022-07-04T08:25:40",
          total_price: "150000000000000000",
          payment_token: {
            symbol: "ETH",
            address: "0x0000000000000000000000000000000000000000",
            image_url: "https://openseauserdata.com/files/6f8e2979d428180222796ff4a33ab929.svg",
            name: "Ether",
            decimals: 18,
            eth_price: "1.000000000000000",
            usd_price: "1097.799999999999955000"
          },
          transaction: {
            block_hash: "0x2a52104419c6aa844827ba96362a0ea5d7d677e9e8d665adc7937c8536f5f8f6",
            block_number: "15074902",
            from_account: {
              user: {
                username: "eieiei_nft"
              },
              address: "0xa147b90e30d82fd6b45ef16bb409a782a6386de2",
              config: ""
            },
            id: 415352212,
            timestamp: "2022-07-04T08:25:40",
            to_account: {
              user: nil,
              address: "0x7f268357a8c2552623316e2562d90e642bb538e5",
              config: ""
            },
            transaction_hash: "0x3b5214a75f3edd402fd8dd809a295e4f02873daf97bc87ce302e5eed751a334b",
            transaction_index: "69"
          },
          created_date: "2022-07-04T08:25:44.116914",
          quantity: "1",
          collection_slug: "voxelverylonganimals",
          contract_address: "0x7f268357a8c2552623316e2562d90e642bb538e5",
          id: 7069242964,
          is_private: true,
          owner_account: nil,
          seller: {
            user: {
              username: "VoxelVeryLongAnimals"
            },
            address: "0x655a01706cf1bd04df0f8761febb1e9cfc1bc085",
            config: ""
          },
          starting_price: nil,
          to_account: nil,
          winner_account: {
            user: {
              username: "eieiei_nft"
            },
            address: "0xa147b90e30d82fd6b45ef16bb409a782a6386de2",
            config: ""
          },
          listing_time: "2022-07-04T08:14:56"
        }
      ]
    }
  }

  describe "#fetch_flip_data_by_nft" do
    it "should fetch flip data by nft" do
      end_at = Time.now
      start_at = end_at - 1.hour
      stub_request(:get, "https://api.opensea.io/api/v1/events?only_opensea=false&collection_slug=#{nft.opensea_slug}&event_type=successful&occurred_after=#{start_at.to_i}&occurred_before=#{end_at.to_i}").
          with(
            headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
            }).
          to_return(status: 200, body: data.to_json, headers: {})

      described_class.fetch_flip_data_by_nft(nft: nft, start_at: start_at, end_at: end_at)
      expect(NftFlipRecord.count).to eq(0)
    end
  end

  describe "#fetch_last_trade" do
    it "should fetch the last trade" do
      stub_request(:get, "https://api.opensea.io/api/v1/events?only_opensea=false&token_id=#{record.token_id}&asset_contract_address=#{record.token_address}&event_type=successful&account_address=#{record.fliper_address}").
          with(
            headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
            }).
          to_return(status: 200, body: data.to_json, headers: {})

      result = described_class.fetch_last_trade(record.token_address, record.fliper_address, record.slug, "manual", record.token_id, "ERC721")
      expect(result).to be_nil
    end
  end

  describe "#fetch_flip_data" do
    it "should fetch flip data" do
      end_at = Time.now
      start_at = end_at - 1.hour
      stub_request(:get, "https://api.opensea.io/api/v1/events?only_opensea=false&event_type=successful&occurred_after=#{start_at.to_i}&occurred_before=#{end_at.to_i}").
          with(
            headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
            }).
          to_return(status: 200, body: data.to_json, headers: {})

      described_class.fetch_flip_data(start_at: start_at, end_at: end_at)
      expect(NftFlipRecord.count).to eq(0)
    end
  end
end