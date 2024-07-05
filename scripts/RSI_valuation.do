getsymbols AAPL AMD F HPE KOS MSFT MU NVDA OXY, clear
rename daten date
gen year = year(date)
order year, after(date)
replace period = month(date)
order period, after(date)
format %9.0g period
tsset date
format %tdMonth_dd,_CCYY date

sort date

local stocks "AAPL AMD F HPE KOS MSFT MU NVDA OXY"

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
    
    * Generate buy_at/sell_at signals
    gen signal_`stock' = 0
    replace signal_`stock' = 1 if rsi_`stock' < 30  
    replace signal_`stock' = -1 if rsi_`stock' > 70  
    
    * Initialize trade return and variables to track buy_at/sell_at signals
    gen trade_return_`stock' = .
    gen buy_at_date_`stock' = .
    gen sell_at_date_`stock' = .
    
    * Calculate returns based on trading signals
    local buy_at_price = .
    local buy_at_index = .

    forvalues i = 1/`=_N' {
        * Check for sell_at signal and store buy_at price
        if signal_`stock'[`i'] == -1 & missing(`buy_at_price') {
            local buy_at_price = close_`stock'[`i']
            local buy_at_index = `i'
        }
        
        * Check for buy_at signal and calculate return
        if signal_`stock'[`i'] == 1 & !missing(`buy_at_price') {
            local sell_at_price = close_`stock'[`i']
            replace trade_return_`stock' = (`sell_at_price' - `buy_at_price') / `buy_at_price' * 100 in `i'
            replace buy_at_date_`stock' = date[`buy_at_index'] in `i'
            replace sell_at_date_`stock' = date[`i'] in `i'
            local buy_at_price = .
            local buy_at_index = .
        }
    }
}

* Optional: Drop temporary variables (clean up)
foreach stock of local stocks {
    drop gain_`stock' loss_`stock' mean_gain_`stock' mean_loss_`stock' rs_`stock' price_change_`stock'
}

* Create buy_at/sell_at RSI threshold
gen buy_at = 35
gen sell_at = 55
export delimited using "C:\Users\jkemper\OneDrive - Texas Tech University\Git\JARSTCO\data\RSI_valuations.csv", replace

*RSI Graphs 

twoway (line rsi_AAPL date if year > 2022) (line buy_at date if year > 2022, yaxis(2) lcolor(green)) (line sell_at date if year > 2022, yaxis(2) lcolor(red)), title(AAPL Relative Strength Index (RSI)) ytitle(, color(%0)) xtitle(, color(%0)) note(RSI of 40/60 equals buy_at/sell_at)
graph export "C:\Users\jkemper\OneDrive - Texas Tech University\Git\JARSTCO\graphs\AAPL_rsi.jpg", as(jpg) name("Graph") quality(100) replace
twoway (line rsi_AMD date if year > 2022) (line buy_at date if year > 2022, yaxis(2) lcolor(green)) (line sell_at date if year > 2022, yaxis(2) lcolor(red)), title(AMD Relative Strength Index (RSI)) ytitle(, color(%0)) xtitle(, color(%0))
graph export "C:\Users\jkemper\OneDrive - Texas Tech University\Git\JARSTCO\graphs\AMD_rsi.jpg", as(jpg) name("Graph") quality(100) replace
twoway (line rsi_F date if year > 2022) (line buy_at date if year > 2022, yaxis(2) lcolor(green)) (line sell_at date if year > 2022, yaxis(2) lcolor(red)), title(F Relative Strength Index (RSI)) ytitle(, color(%0)) xtitle(, color(%0))
graph export "C:\Users\jkemper\OneDrive - Texas Tech University\Git\JARSTCO\graphs\F_rsi.jpg", as(jpg) name("Graph") quality(100) replace
twoway (line rsi_HPE date if year > 2022) (line buy_at date if year > 2022, yaxis(2) lcolor(green)) (line sell_at date if year > 2022, yaxis(2) lcolor(red)), title(HPE Relative Strength Index (RSI)) ytitle(, color(%0)) xtitle(, color(%0))
graph export "C:\Users\jkemper\OneDrive - Texas Tech University\Git\JARSTCO\graphs\HPE_rsi.jpg", as(jpg) name("Graph") quality(100) replace
twoway (line rsi_KOS date if year > 2022) (line buy_at date if year > 2022, yaxis(2) lcolor(green)) (line sell_at date if year > 2022, yaxis(2) lcolor(red)), title(KOS Relative Strength Index (RSI)) ytitle(, color(%0)) xtitle(, color(%0))
graph export "C:\Users\jkemper\OneDrive - Texas Tech University\Git\JARSTCO\graphs\KOS_rsi.jpg", as(jpg) name("Graph") quality(100) replace
twoway (line rsi_MSFT date if year > 2022) (line buy_at date if year > 2022, yaxis(2) lcolor(green)) (line sell_at date if year > 2022, yaxis(2) lcolor(red)), title(MSFT Relative Strength Index (RSI)) ytitle(, color(%0)) xtitle(, color(%0))
graph export "C:\Users\jkemper\OneDrive - Texas Tech University\Git\JARSTCO\graphs\MSFT_rsi.jpg", as(jpg) name("Graph") quality(100) replace
twoway (line rsi_NVDA date if year > 2022) (line buy_at date if year > 2022, yaxis(2) lcolor(green)) (line sell_at date if year > 2022, yaxis(2) lcolor(red)), title(NVDA Relative Strength Index (RSI)) ytitle(, color(%0)) xtitle(, color(%0))
graph export "C:\Users\jkemper\OneDrive - Texas Tech University\Git\JARSTCO\graphs\NVDA_rsi.jpg", as(jpg) name("Graph") quality(100) replace
twoway (line rsi_OXY date if year > 2022) (line buy_at date if year > 2022, yaxis(2) lcolor(green)) (line sell_at date if year > 2022, yaxis(2) lcolor(red)), title(OXY Relative Strength Index (RSI)) ytitle(, color(%0)) xtitle(, color(%0))
graph export "C:\Users\jkemper\OneDrive - Texas Tech University\Git\JARSTCO\graphs\OXY_rsi.jpg", as(jpg) name("Graph") quality(100) replace

gen t = _n
egen max = max(t)
graph bar (sum) rsi_AAPL rsi_AMD rsi_F rsi_HPE rsi_KOS rsi_MSFT rsi_MU rsi_NVDA rsi_OXY if t == max


