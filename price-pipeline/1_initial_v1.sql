SELECT
    DATE_FORMAT(timestamp, '%H:%i - %d.%m.%Y') as date,
    price
    --,symbol
FROM
    prices_solana.hour
where
    contract_address = '{{contract_address}}'
ORDER BY
    month ASC,
    DATE_FORMAT(timestamp, '%d'),
    DATE_FORMAT(timestamp, '%H:%i')
