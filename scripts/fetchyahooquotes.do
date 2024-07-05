
sjlog using fetchyahooquotes1, replace
fetchyahooquotes  MSFT, freq(d) chg(ln) start("01jan2010") end("31dec2010") ff3
summarize
sjlog close, replace

sjlog using fetchyahooquotes2, replace
fetchyahooquotes MSFT IBM XYZ, freq(m) chg(ln)
summarize
list in 1/3
sjlog close, replace

sjlog using fetchyahooquotes3, replace
fetchyahooquotes IBM GOOG ^GSPC BMW.DE, freq(d) field(h l o)
summarize
sjlog close, replace


sjlog using fetchyahooquotes4, replace
fetchyahooquotes IBM BMW.DE F, freq(v)
summarize
sjlog close, replace


sjlog using fetchyahooquotes5, replace
fetchyahookeystats IBM GOOG ^GSPC BMW.DE, field(n s l1 a b d1 g h k e n s k e L) save(my_portfolio)
sjlog close, replace

sjlog using fetchyahooquotes6, replace
describe
sjlog close, replace

sjlog using fetchyahooquotes7, replace
summarize
sjlog close, replace
