SELECT DATE_TRUNC('month', block_time) as dt, SUM (count(*)) OVER (ORDER BY DATE_TRUNC('month', block_time)) as n_bans 
FROM ethereum.logs
WHERE contract_address = 0xdac17f958d2ee523a2206206994597c13d831ec7
  AND topic0 = 0x42e160154868087d6bfdc0ca23d96a1c1cfa32f1b72ba9ba27b69b98a0d819dc
group by 1
