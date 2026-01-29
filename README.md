# rGoldETF

## Overview

rGoldETF is an R package for fetching, analyzing, and visualizing Gold ETF (GLD) data using the [Twelve Data API](https://twelvedata.com/). It provides a comprehensive toolkit for:

- Retrieving real-time and historical GLD price data
- Fetching gold spot prices (XAU/USD)
- Calculating technical indicators (SMA, EMA, RSI, MACD, Bollinger Bands)
- Comparing multiple gold ETFs
- Comparing Gold vs Bitcoin price trends
- Creating professional visualizations

## Installation

You can install the development version of rGoldETF from GitHub:

```r
# install.packages("devtools")
devtools::install_github("xuanruiqiu/DATA_534_Project", subdir = "rGoldETF")
```

## Setup

Before using the package, you need to obtain a free API key from [Twelve Data](https://twelvedata.com/pricing):

```r
library(rGoldETF)

# Set your API key
Sys.setenv(TWELVE_DATA_API_KEY = "your_api_key_here")
# Or use the helper function
gld_set_api_key("your_api_key_here")
```

**Note:** The free tier allows 8 API calls per minute.

## Usage

### Real-Time Prices

```r
# Get current GLD price
gld_price <- get_gld_price()

# Get gold spot price (XAU/USD)
gold_spot <- get_gold_spot_price()

# Get any ETF price
iau_price <- get_etf_price("IAU")
```

### Historical Data

```r
# Get GLD historical data
history <- get_gld_history(
  start_date = "2024-01-01",
  end_date = "2024-12-31"
)

# Get gold spot history
gold_history <- get_gold_spot_history(
  start_date = "2024-01-01",
  end_date = "2024-12-31"
)

# Get any ETF history
iau_history <- get_etf_history("IAU", "2024-01-01", "2024-12-31")
```

### Technical Indicators

```r
# Calculate technical indicators (local calculation, no API call)
data_with_indicators <- get_technical_indicators(
  history,
  indicators = c("sma", "ema", "rsi", "macd", "bollinger"),
  periods = list(sma = 20, ema = 12, rsi = 14)
)
```

### Visualization

```r
# Basic price chart
plot_gld_chart(history)

# Chart with moving averages
plot_gld_chart(data_with_indicators, indicators = c("sma", "ema"))

# Candlestick chart
plot_gld_chart(history, type = "candlestick")

# Compare Gold vs Bitcoin
plot_asset_comparison(start_date = Sys.Date() - 30, end_date = Sys.Date())
```

### Compare ETFs

```r
# Compare multiple gold ETFs
comparison <- compare_gold_etfs(
  symbols = c("GLD", "IAU", "SGOL"),
  start_date = "2024-01-01",
  end_date = "2024-12-31",
  delay = 8  # Respect API rate limits
)
```

### Utility Functions

```r
# Search for gold-related symbols
gold_symbols <- search_gold_symbols("gold")

# Check market state
market_state <- get_market_state("NYSE")
```

## Available Functions

| Function | Description |
|----------|-------------|
| `get_gld_price()` | Get current GLD ETF price |
| `get_gld_history()` | Get historical GLD data |
| `get_gold_spot_price()` | Get gold spot price (XAU/USD) |
| `get_gold_spot_history()` | Get gold spot historical data |
| `get_etf_price()` | Get any ETF current price |
| `get_etf_history()` | Get any ETF historical data |
| `get_technical_indicators()` | Calculate technical indicators |
| `plot_gld_chart()` | Create price charts |
| `plot_asset_comparison()` | Compare Gold vs Bitcoin with normalized prices |
| `compare_gold_etfs()` | Compare multiple gold ETFs |
| `search_gold_symbols()` | Search for gold-related symbols |
| `get_market_state()` | Check market open/close status |
| `gld_set_api_key()` | Set API key |

## Documentation

For detailed documentation and examples, see the package vignette:

```r
vignette("rGoldETF-introduction", package = "rGoldETF")
```

## Team

- Xuanrui Qiu
- Yaojun Liu
- Ruochen Yang

## License

MIT License
