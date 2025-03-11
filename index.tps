// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © baotvdn

//@version=6
strategy("Simple Pullback Strategy", 
     overlay=true, 
     initial_capital=50000,
     default_qty_type=strategy.percent_of_equity, 
     default_qty_value=100, // 100% of balance invested on each trade
     commission_type=strategy.commission.cash_per_contract, 
     commission_value=0.005) // Interactive Brokers rate

// Get user input
i_ma1           = input.int(title="MA 1 Length", defval=200, step=10, group="Strategy Parameters", tooltip="Long-term MA")
i_ma2           = input.int(title="MA 2 Length", defval=21, step=10, group="Strategy Parameters", tooltip="Short-term MA")
i_maDistance   = input.int(title="MA Distance", defval=10, group="Strategy Parameters")
i_lowerClose    = input.bool(title="Exit On Lower Close", defval=false, group="Strategy Parameters", tooltip="Wait for a lower-close before exiting above MA2")
i_startTime     = input.time(title="Start Filter", defval=timestamp("01 Jan 1995 13:30 +0000"), group="Time Filter", tooltip="Start date & time to begin searching for setups")
i_endTime       = input.time(title="End Filter", defval=timestamp("1 Jan 2099 19:30 +0000"), group="Time Filter", tooltip="End date & time to stop searching for setups")
i_stoploss      = input.int(title = "Stop Loss Point", defval = 30, group = "Strategy Parameters")

// Get indicator values
ma1 = ta.sma(close, i_ma1)
ma2 = ta.sma(close, i_ma2)
ma29 = ta.ema(close, 29)
ma51 = ta.ema(close, 51)

// Check filter(s)
f_dateFilter = time >= i_startTime and time <= i_endTime

// Check buy/sell conditions
var float buyPrice = 0
// var float stopLossPrice = na

// buyCondition    = close > ma1 and close < ma2 and strategy.position_size == 0 and f_dateFilter
buyCondition    = close > ma1 and close < ma2 and strategy.position_size == 0 and f_dateFilter and ma2 - ma1 > i_maDistance

// Enter positions
if buyCondition
    strategy.entry(id="Long", direction=strategy.long, comment="Signal@" + str.tostring(close, "#.##"))

if buyCondition[1]
    buyPrice := open

sellCondition   = close > ma2 and strategy.position_size > 0 and (not i_lowerClose or close < close[1])
// sellCondition   = strategy.position_size > 0 and (not i_lowerClose or close < close[1])
stopCondition   = strategy.position_size > 0 and buyPrice - low >= i_stoploss

// Exit positions
if sellCondition or stopCondition
    strategy.close(id="Long", comment="Exit@" + str.tostring(close, "#.##") + (stopCondition ? " SL=true " : ""))
    buyPrice := na

// if sellCondition
//     strategy.close(id="Long", comment="Exit@" + str.tostring(close, "#.##"))

// if strategy.position_size > 0
//     stopLossPrice = strategy.position_avg_price - i_stoploss
//     strategy.exit(id="StopLoss", from_entry="Long", stop=stopLossPrice)

// Draw pretty colors
plot(ma1, color=color.blue)
plot(ma2, color=color.orange)
plot(ma29, color = color.yellow)
plot(ma51, color = color.lime)


