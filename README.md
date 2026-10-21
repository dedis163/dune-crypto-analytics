# Dune Crypto Analytics

On-chain analytics built on [Dune](https://dune.com): token-holder analysis on Solana and Base, and a price-data pipeline. All SQL is as it was used.

All of these queries are my own work.

**What this repo is:** a presentation of work that was originally built as dashboards and queries on Dune. The dashboards run on Dune; this repo only shows the SQL behind them and explains what each one was for.

## Why I built this

Blockchains are public, but wallets are anonymous. A big investor who wants to stay anonymous will not buy a coin from the wallet everyone knows is theirs. They create a fresh wallet, send it new money, and make one or a few large buys of a specific coin.

That leaves a pattern that can be measured: **big buys from newly created wallets.** One such wallet means little. If a coin suddenly has a lot of them, someone may be quietly building a position, and the coin may be worth a closer look.

These queries measure that. They find the wallets holding a token, filter for large holdings, and (on Base) for wallets that only recently became active. The Solana scanner lists the wallets above a dollar threshold such as $1,000 or $10,000. Each wallet links to SolFM and SolScan, where I check its history: was the wallet freshly created, or was its first transfer from a centralized exchange? The price pipeline provides the price data. This is a signal, not proof: a new wallet can also just be a new user.

| Project | Chain | What |
|---|---|---|
| [Solana holder scanner](solana-holder-scanner/) | Solana | Top holders of a token, by dollar threshold |
| [Price pipeline](price-pipeline/) | Solana | Hourly token price history, initial load and incremental update |
| [Base stealth holders](base-stealth-holders/) | Base | Holders by balance, account age and cumulative distribution |

## Solana holder scanner

Original work. v4 is a fork of my own v3.

**Question:** for a Solana token, how many wallets hold above a given dollar amount, and how does that change when the threshold changes?

**How it was used:** the minimum holding is a parameter, so the same query was run at different dollar thresholds ($1,000 wallets, $10,000 wallets) on a coin around a $100,000 market cap, to compare how the holder picture changes. The scanner is the first step: it produces the list of large holders, and the SolFM and SolScan links on each row are used for the second step, checking whether each wallet is new and where its first transfer came from.

**What it returns:** for any token mint address, the holders with their balance, share of supply, and USD value, filtered by the minimum holding. Each row links to SolFM and SolScan. The dashboard shows the result as a line chart and pie charts.

| File | Price source |
|---|---|
| `solana-holder-scanner/manual_v3.sql` | typed in by hand (`price` parameter), "for more accuracy"; also lets you test a hypothetical price |
| `solana-holder-scanner/auto_v4.sql` | forked from v3; looks up the last price Dune recorded for the token, top 50 only |

| Parameter | Meaning |
|---|---|
| `contract_address` | token mint address |
| `min_token_holding_in_usdt` | ignore holders below this USD value |
| `total_tokens` | total token supply, used for the ownership percentage |
| `price` | (manual v3 only) token price in USD |

## Price pipeline

Original work. Hourly Solana token prices from `prices_solana.hour`, built in three steps.

| File | What |
|---|---|
| `price-pipeline/3_last_price_v1.sql` | the last price Dune recorded for a token (first version) |
| `price-pipeline/1_initial_v1.sql` | full hourly price history for a token |
| `price-pipeline/2_update_v1.sql` | forked from the initial load; only rows after `last_date_recorded`, for incremental updates |

## Base stealth holders

Base chain token holder analysis: addresses holding the token, active within the past N days, with holdings, account age, cumulative distribution and links to BaseScan and Debank.

**These are forks with changes, not copies.**

- `stealth_test.sql` started from my earlier query `stealth-money-graph-no-prices-dunev2`, a "no prices" version, and was modified.
- `stealth_manual_v1.sql` is a fork of `stealth_test.sql` and adds:
  - a typed `token_price` parameter and a `value_in_usd` column
  - a USD threshold (`min_value_usdt`) in place of the token-amount threshold (`min_value`)
  - BaseScan links for Base addresses (the test version links to Etherscan)

## Repo layout

```
solana-holder-scanner/   manual v3, auto v4
price-pipeline/          initial, update, last price
base-stealth-holders/    test, manual v1
```
