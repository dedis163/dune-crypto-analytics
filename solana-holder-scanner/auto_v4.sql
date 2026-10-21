/*
GENERAL NOTES

I couldnt use the query_4367876 directly so I pasted its code in the price_query, the upgrade would be if I used the
                    "SELECT last_dune_recorded_price_of_token FROM "query_4367876(token_ca = '{{contract_address}}')"" format
*/

WITH price_query AS (
    --SELECT last_dune_recorded_price_of_token FROM "query_4367876(token_ca = '{{contract_address}}')"
    SELECT
        price AS last_dune_recorded_price_of_token
    FROM
        prices_solana.hour
    where
        contract_address = '{{contract_address}}'
    ORDER BY
        timestamp DESC
        LIMIT 1
)

SELECT
    lb.token_balance_owner,
    (ROUND(SUM(lb.token_balance),2)/{{total_tokens}}) AS Total_Percntg,
    SUM(lb.token_balance) AS total_balance,
    CEILING(SUM(lb.token_balance) * (SELECT last_dune_recorded_price_of_token FROM price_query)) AS Value_in_usdt,
    '<a href=https://solana.fm/address/' || cast(lb.token_balance_owner as varchar) || ' /transactions?cluster=mainnet-alpha target=_blank>SolFM</a>' as solfm_link,
    '<a href=https://solscan.io/account/' || cast(lb.token_balance_owner as varchar) || '  target=_blank>SolScan</a>' as solscan_link
FROM
    solana_utils.latest_balances AS lb
WHERE
    lb.token_mint_address = '{{contract_address}}'
GROUP BY lb.token_balance_owner
HAVING
    SUM(lb.token_balance) * (SELECT last_dune_recorded_price_of_token FROM price_query) > {{min_token_holding_in_usdt}}
ORDER BY
total_balance  DESC
LIMIT 50
