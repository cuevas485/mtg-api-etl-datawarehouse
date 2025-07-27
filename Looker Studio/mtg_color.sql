create or replace table mtg_dataset.unq_set_card_color_sum as
with cards_rk as (
select fc.released_at, fc.id, fc.name, fc.cmc, fc.mana_cost, fc.is_multicolor, fc.is_colorless, fc.set_id
,row_number()over(partition by fc.name, fc.set_id order by fc.id) rn
from `mtg_dataset.fact_card` fc
),
unique_cards_set as ( 
select *
from cards_rk
where rn=1
),
unique_cards_colors_xp as (
select ucs.released_at, ucs.id, ucs.name, ucs.cmc, ucs.mana_cost, ucs.is_multicolor, ucs.is_colorless
,dc.color_identity
,ds.set_name
, case when dl.commander = 'legal' then 'Y' else 'N' end commander_legal
,1 card_cnt
from unique_cards_set ucs
left outer join `mtg_dataset.dim_colors` dc
on ucs.id = dc.id
join `mtg_dataset.dim_set`ds
on ucs.set_id = ds.set_id
join `mtg_dataset.dim_legalities` dl
on ucs.id = dl.id
)
select set_name,commander_legal,is_multicolor, is_colorless, color_identity
, case when color_identity = 'B' then 'Black'
       when color_identity = 'G' then 'Green'
       when color_identity = 'U' then 'Blue'
       when color_identity = 'R' then 'Red'
       when color_identity = 'W' then 'White'
       when color_identity is null then 'Colorless'
       else 'Review'
        end as color_label
, sum(card_cnt) card_cnt
from unique_cards_colors_xp
group by 1,2,3,4,5
;




