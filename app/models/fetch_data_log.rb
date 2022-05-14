class FetchDataLog < ApplicationRecord
  enum fetch_type: [:auto, :manual]
end
