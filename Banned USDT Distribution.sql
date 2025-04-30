WITH banned_addresses as (
    SELECT 
      substring(data from 13) as wallet_address
    FROM ethereum.logs
    WHERE
      contract_address = 0xdac17f958d2ee523a2206206994597c13d831ec7
      AND topic0 = 0x42e160154868087d6bfdc0ca23d96a1c1cfa32f1b72ba9ba27b69b98a0d819dc
), 

transfers AS (
    SELECT "from", "to", value
    FROM erc20_ethereum.evt_Transfer
    WHERE contract_address = 0xdac17f958d2ee523a2206206994597c13d831ec7
),

usdt_balances as (
    SELECT
        wallet_address,
        SUM(CASE WHEN direction = 'in' THEN value ELSE 0 END) as sum_in,
        SUM(CASE WHEN direction = 'out' THEN value ELSE 0 END) as sum_out
    FROM (
        SELECT "to" as wallet_address, value, 'in' as direction
        FROM transfers
    
        UNION ALL
    
        SELECT "from" as wallet_address, value, 'out' as direction
        FROM transfers
    ) as subquery
    where wallet_address IN (SELECT * FROM banned_addresses)
    GROUP BY wallet_address
    
)
select wallet_address, (COALESCE(sum_in, 0) - COALESCE(sum_out, 0)) / 1000000 as balance
from usdt_balances
where wallet_address in (select * from banned_addresses)
