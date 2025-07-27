create or replace table mtg_dataset.fact_price_wk_v as
with price_adj as (
  select 
       fp.price_fact_id
      ,fc.id AS card_id
      ,fc.type_id
      ,fc.name
      ,fp.date_loaded
      ,date_trunc(fp.date_loaded,week(monday)) AS week_start
      ,fp.prices_usd
    from `mtg_dataset.fact_price` fp
    join `mtg_dataset.fact_card` fc
      on fp.id = fc.id
),
price_rk as (
  select adj.*
    ,row_number()over(partition by card_id, week_start order by date_loaded asc) rn_asc
    ,row_number()over(partition by card_id, week_start order by date_loaded desc) rn_desc
  from price_adj adj
),
card_price_wk_v as (
select
     card_id
    ,type_id
    ,name
    ,week_start
    ,max(case when rn_asc = 1 then prices_usd end) as start_prc_monday
    ,max(case when rn_desc = 1 then prices_usd end) as end_prc_sunday
  from price_rk
  group by 1,2,3,4
  order by week_start
),
card_price_wk_v_calc as (
select v.*
, round(end_prc_sunday - start_prc_monday,2) as price_diff
, round(safe_divide(end_prc_sunday - start_prc_monday, start_prc_monday) * 100,2) as pct_change
from card_price_wk_v v
)
select v.card_id, v.name, dt.types, dt.subtypes, v.week_start, v.start_prc_monday, v.end_prc_sunday, v.price_diff, v.pct_change
    ,di.normal
    ,case when dl.commander = 'legal' then 'Y' else 'N' end as commander_legality
    ,1 sum
from card_price_wk_v_calc v
left outer join `mtg_dataset.dim_image` di
      on v.card_id = di.id
join `mtg_dataset.dim_legalities` dl
      on v.card_id = dl.id
join `mtg_dataset.dim_type` dt
  on v.type_id = dt.type_id
where v.price_diff is not null
;
