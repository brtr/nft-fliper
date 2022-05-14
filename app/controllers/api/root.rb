module API
  class Root < Grape::API
    version 'v1', using: :path
    prefix :api
    format :json

    mount API::V1::Nfts
  end
end