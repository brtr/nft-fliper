class FetchNftFlipRecordsJob < ApplicationJob
  queue_as :daily_job

  NFTS = ["bored-ape-kennel-club", "autoglyphs", "pegz", "azuki", "rtfkt-nike-cryptokicks",
          "ikb-cachet-de-garantie", "bored-ape-yacht-club", "beanz-official", "colorglyphs",
          "nouns", "tom-sachs-rockets", "wolfgamelegacy", "cryptopunks", "meebits",
          "mutant-ape-yacht-club", "fvck-crystal", "10ktf", "cryptoadz", "gutter-cat-gang",
          "mclarenmsolabgenesis", "otherdeed", "proof-moonbirds", "doodles"]

  def perform
    NFTS.each do |slug|
      FetchNftFlipDataByNftJob.perform_later(slug)
    end
  end
end