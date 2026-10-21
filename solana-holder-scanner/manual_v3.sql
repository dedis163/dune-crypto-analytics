/*

GENERAL NOTES

This is the manual one for more accuracy

*/

SELECT
    lb.token_balance_owner,
    (ROUND(SUM(lb.token_balance),2)/{{total_tokens}}) AS Total_Percntg,
    SUM(lb.token_balance) AS total_balance,
    CEILING(SUM(lb.token_balance) * {{price}}) AS Value_in_usdt,
    '<a href=https://solana.fm/address/' || cast(lb.token_balance_owner as varchar) || ' /transactions?cluster=mainnet-alpha target=_blank>SolFM</a>' as solfm_link,
    '<a href=https://solscan.io/account/' || cast(lb.token_balance_owner as varchar) || '  target=_blank>SolScan</a>' as solscan_link
FROM
    solana_utils.latest_balances AS lb
WHERE
    lb.token_mint_address = '{{contract_address}}' /*? JxxWsvm9jHt4ah7DT9NuLyVLYZcZLUdPD93PcPQ71Ka */
GROUP BY lb.token_balance_owner
HAVING
    SUM(lb.token_balance) * {{price}} > {{min_token_holding_in_usdt}}
ORDER BY
total_balance  DESC





Token Distribution Analysis

* Total_Percntg: Identifies the percentage of total tokens held by each owner to assess distribution concentration.
* total_balance: Measures the total token holdings per owner to understand ownership scale.
* Value_in_usdt: Converts token holdings to USD to evaluate financial impact.
* solfm_link & solscan_link: Provides quick access to transaction details for transparency and verification.
