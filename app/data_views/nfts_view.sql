DROP MATERIALIZED VIEW IF EXISTS nfts_view;
CREATE MATERIALIZED VIEW nfts_view AS
    WITH histories_today AS (
      SELECT 
        nft_id, 
        event_date, 
        floor_price,
        eth_floor_price,
        volume,
        eth_volume,
        sales,
        eth_volume_rank,
        bchp,
        bchp_6h,
        bchp_12h,
        median
      FROM nft_histories
      WHERE event_date = CURRENT_DATE - interval '1 day'
    ), histories_24h AS (
      SELECT
        nft_id,
        event_date,
        floor_price,
        eth_floor_price,
        volume,
        eth_volume,
        sales,
        bchp,
        eth_volume_rank
      FROM nft_histories
      WHERE event_date = CURRENT_DATE - interval '2 day'
    ), histories_3d AS (
      SELECT
        nft_id,
        event_date,
        floor_price,
        eth_floor_price,
        volume,
        eth_volume,
        sales,
        eth_volume_rank
      FROM nft_histories
      WHERE event_date = CURRENT_DATE - interval '3 day'
    ), results AS (
      SELECT 
      n.id::INTEGER as nft_id,
      n.chain_id,
      n.name,
      n.slug,
      n.logo,
      n.address,
      n.opensea_url,
      n.total_supply,
      n.floor_cap,
      n.eth_floor_cap,
      n.updated_at,
      n.listed,
      n.listed_ratio,
      h1.sales as sales_24h,
      h1.bchp as bchp,
      h1.bchp_6h as bchp_6h,
      h1.bchp_12h as bchp_12h,
      h1.median as median,
      ROUND(h1.floor_price, 2) as floor_price_24h,
      h1.eth_floor_price as eth_floor_price_24h,
      h1.volume as volume_24h,
      h1.eth_volume as eth_volume_24h,
      h1.eth_volume_rank as eth_volume_rank,
      h2.eth_volume_rank as eth_volume_rank_24h,
      h3.eth_volume_rank as eth_volume_rank_3d,
      COALESCE((case when n.variation > 0 then n.variation else (h1.eth_floor_price - h2.eth_floor_price) / NULLIF(h2.eth_floor_price,0) end ), 0) as variation,
      COALESCE((case when h2.eth_volume_rank = 0 then h1.eth_volume_rank else h2.eth_volume_rank - h1.eth_volume_rank end ), 0) as volume_rank_24h,
      COALESCE((case when h3.eth_volume_rank = 0 then h1.eth_volume_rank else h3.eth_volume_rank - h1.eth_volume_rank end ), 0) as volume_rank_3d,
      COALESCE((case when h1.bchp_6h = 0 then h1.bchp else h1.bchp - h1.bchp_6h end ), 0) as bchp_6h_change,
      COALESCE((case when h1.bchp_12h = 0 then h1.bchp else h1.bchp - h1.bchp_12h end ), 0) as bchp_12h_change
      FROM nfts as n
      LEFT JOIN histories_today as h1 on h1.nft_id = n.id
      LEFT JOIN histories_24h as h2 on h2.nft_id = n.id
      LEFT JOIN histories_3d as h3 on h3.nft_id = n.id
    )
    SELECT * FROM results;

CREATE INDEX nft_id_on_nfts_view             ON nfts_view USING BTREE(nft_id);
CREATE INDEX name_on_nfts_view               ON nfts_view USING BTREE(name);
CREATE UNIQUE INDEX unique_id_name_nfts_view ON nfts_view USING BTREE(nft_id, name);
