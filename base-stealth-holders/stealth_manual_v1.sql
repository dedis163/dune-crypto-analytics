/*
Base chain token holder analysis: Identifies addresses holding ≥1 token with USD value ≥minimum threshold, active within past N days, showing holdings balance, USD value, account age, and cumulative distribution with direct links to BaseScan & Debank.
*/

with holdings as (
    select address, holding, {{token_address}} as contract_address from
        (select sum(total) as holding, address from
            (select sum(cast(value as double)/pow(10,COALESCE(b.decimals, {{decimals}}))) as total, to as address
            from erc20_base.evt_transfer a
            left join tokens.erc20 b on a.contract_address = b.contract_address
            where a.contract_address = {{token_address}}
            group by 2

            union all

            select -sum(cast(value as double)/pow(10,COALESCE(b.decimals, {{decimals}}))) as total, "from" as address
            from erc20_base.evt_transfer a
            left join tokens.erc20 b on a.contract_address = b.contract_address
            where a.contract_address = {{token_address}}
            group by 2
            ) t
            group by address) t
        where holding >= 1
),

active_since as (
    select distinct to as address, min(evt_block_time) over (partition by to) as active_since
    from erc20_base.evt_transfer
    --where substring("data", 17, 20) = '\xb7e0e36cbb50845f181049a361cccc1a4809c2d6'
    where to IN (select address from holdings)
),

age as (
    select address, active_since
    from active_since
    where cast(active_since as timestamp) >= now() - interval '{{age}}' day
),

temp as (
    select
    h.address, h.contract_address, h.holding as token_holdings,
    h.holding * {{token_price}} as value_in_usd,
    date_diff('day', active_since, now()) as age, active_since,

    '<a href=https://basescan.org/address/' || cast(h.address as varchar) || ' target=_blank>BaseScan</a>' as etherscan_link,
    '<a href=https://debank.com/profile/' || cast(h.address as varchar) || ' target=_blank>Debank</a>' as debank_link
    from holdings h
    join age a on a.address = h.address
    where h.holding * {{token_price}} >= {{min_value_usdt}}
    order by active_since ASC
),

row_temp as (
    select
    ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS row, *
    from temp
)

select *, sum(t.token_holdings) over(order by t.row) as cumu_holdings
from row_temp t
