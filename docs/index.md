# Sporting Stars Smart Contracts

## SportValueCoin
utility token
fixed supply - 100M, 18 decimals
burnable
used for:
- payouts
- commissions
- extra features
- in trading pairs
- network maintenance and development paymengts

## PlayerToken
is a tradeable asset
represents a sports player
mintable by the market contract
burnable

## Team Token
is a tradeable asset
represents a team
mintable by the market contract but needs to be backed by playertokens
burnable

## MarketManager
represents a market.
 
makes payouts based on results (pool bet concept) 
funded by crowdsale.
crowdsale contract, mints new tokens each season.
tokens are minted if no stock exist
buys back tokens on current price
Price is calculated with a delta algorithm.
Later, when tokens will be traded on an exchange, it can still be used to provide liquidity with the price coming from
an oracle.
pays payouts based on sports results provided by a SportResultsOracle in SVCoin from the pre season sale.

payout rules:
- top10 ranked share payouts
- paid weekly
- amount = revenue from newly minted coins for the period (week) distributed like (50%,25%,12%,6%,3%,2%,1%)
- if a token is too cheap and can't be sold to fund the pool, it can't earn payouts

## LiquidityProvider
provides liquidity for traders
has enough SVC to pay for assets
can participate in exchanges or can offer liquidity directly to traders
will use an oracle for price determination or in absence of exchanges in early stages will use an internal formula for the price
when buying newly issued coins those will not move price

## SportResultsOracle
contract that contains sports results for a given tournament
it will be distributed with multiple validators

## BasicSVCExchange
a simple contract to buy/sell SVC coins

