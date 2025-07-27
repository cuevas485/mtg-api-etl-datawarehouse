create or replace table mtg_dataset.mtg_rarity_sum as
with cards_rk as (
  select fc.released_at, fc.id, fc.name, fc.type_id, fc.rarity_id, ds.set_name, ds.set_type,
    row_number() over (partition by fc.name, fc.set_id order by fc.id) rn
  from `mtg_dataset.fact_card` fc
  join `mtg_dataset.dim_set` ds on fc.set_id = ds.set_id
),
unique_cards_set as (
  select released_at, id card_id, name, set_name, set_type, type_id, rarity_id
  from cards_rk
  where rn = 1
),
card_dim_metrics_v as (
  select
     ucs.released_at
    ,ucs.set_name
    ,ucs.name card_name
    ,dt.supertypes
    ,dt.types
    ,dt.subtypes
    ,dr.rarity
    ,di.normal image_url
    ,case when dl.commander = 'legal' then 'Y' when dl.commander is null then 'N' else 'N' end commander_legality
    ,1 card_cnt
  from unique_cards_set ucs
  join `mtg_dataset.dim_type` dt on ucs.type_id = dt.type_id
  join `mtg_dataset.dim_rarity` dr on ucs.rarity_id = dr.rarity_id
  left outer join `mtg_dataset.dim_image` di on ucs.card_id = di.id
  join `mtg_dataset.dim_legalities` dl on ucs.card_id = dl.id
  group by 1,2,3,4,5,6,7,8,9
)
  select
     set_name
    ,rarity
    ,commander_legality
    ,sum(card_cnt) as card_cnt
  from card_dim_metrics_v
  group by 1,2,3
  order by 4 desc
  ;