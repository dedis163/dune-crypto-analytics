SELECT
    DATE_FORMAT(timestamp, '%H:%i - %d.%m.%Y') as date,
    price,
    timestamp
FROM
    prices_solana.hour
where
    contract_address = '{{contract_address}}' AND TIMESTAMP > CAST('{{last_date_recorded}}' AS TIMESTAMP)  --2024-11-18 22:00
ORDER BY
    month ASC,
    DATE_FORMAT(timestamp, '%d'),
    DATE_FORMAT(timestamp, '%H:%i')


Retrieves hourly token price history for a specified Solana token contract address since a given timestamp, formatted with timestamps and sorted chronologically for incremental data updates.
