getsymbols  NVDA AAPL MSFT F OXY , clear
rename daten date
gen year = year(date)
order year, after(date)
replace period = month(date)
order period, after(date)
format %9.0g period
tsset date


sort date

local stocks "NVDA HPE AAPL MSFT F OXY"

foreach stock of local stocks {
    * Calculate the daily price change in percentage
    gen price_change_`stock' = ((close_`stock' - open_`stock') / open_`stock') * 100
    
    * Create gain and loss variables
    gen gain_`stock' = cond(price_change_`stock' > 0, price_change_`stock', 0)
    gen loss_`stock' = cond(price_change_`stock' < 0, -price_change_`stock', 0)
    
    * Calculate the rolling mean for gains and losses over 14 periods
    tssmooth ma mean_gain_`stock' = gain_`stock', window(14) 
    tssmooth ma mean_loss_`stock' = loss_`stock', window(14) 
    
    * Calculate RS (Relative Strength)
    gen rs_`stock' = mean_gain_`stock' / mean_loss_`stock'
    
    * Calculate RSI
    gen rsi_`stock' = 100 - (100 / (1 + rs_`stock'))
    
    * Generate buy/sell signals
    gen signal_`stock' = 0
    replace signal_`stock' = 1 if rsi_`stock' < 30  
    replace signal_`stock' = -1 if rsi_`stock' > 70  
    
    * Initialize trade return and variables to track buy/sell signals
    gen trade_return_`stock' = .
    gen buy_date_`stock' = .
    gen sell_date_`stock' = .
    
    * Calculate returns based on trading signals
    local buy_price = .
    local buy_index = .

    forvalues i = 1/`=_N' {
        * Check for sell signal and store buy price
        if signal_`stock'[`i'] == -1 & missing(`buy_price') {
            local buy_price = close_`stock'[`i']
            local buy_index = `i'
        }
        
        * Check for buy signal and calculate return
        if signal_`stock'[`i'] == 1 & !missing(`buy_price') {
            local sell_price = close_`stock'[`i']
            replace trade_return_`stock' = (`sell_price' - `buy_price') / `buy_price' * 100 in `i'
            replace buy_date_`stock' = date[`buy_index'] in `i'
            replace sell_date_`stock' = date[`i'] in `i'
            local buy_price = .
            local buy_index = .
        }
    }
}

* Optional: Drop temporary variables (clean up)
foreach stock of local stocks {
    drop gain_`stock' loss_`stock' mean_gain_`stock' mean_loss_`stock' rs_`stock' price_change_`stock'
}

export delimited using "C:\Users\jkemper\OneDrive - Texas Tech University\Git\JARSTCO\data\RSI_valuations.csv", replace
