SELECT
    price AS last_dune_recorded_price_of_token
FROM
    prices_solana.hour
where
    contract_address = '"{{token_ca}}'
ORDER BY
    timestamp DESC
    LIMIT 1;
