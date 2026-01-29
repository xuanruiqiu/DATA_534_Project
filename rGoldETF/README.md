# rGoldETF

<!-- badges: start -->
[![R-CMD-check](https://github.com/username/rGoldETF/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/username/rGoldETF/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Overview

rGoldETF is an R package for fetching, analyzing, and visualizing Gold ETF (GLD) data. It provides a comprehensive toolkit for:

- Retrieving real-time and historical GLD price data
- Calculating technical indicators
- Analyzing options chains and implied volatility
- Creating professional visualizations

## Installation

You can install the development version of rGoldETF from GitHub:

```r
# install.packages("devtools")
devtools::install_github("username/rGoldETF")
```

## Usage

```r
library(rGoldETF)

# Get current GLD price
price <- get_gld_price()

# Get historical data
history <- get_gld_history(start_date = "2024-01-01", end_date = "2024-12-31")

# Calculate technical indicators
indicators <- get_technical_indicators(history)

# Get options chain
options <- get_options_chain("GLD")

# Get implied volatility
iv <- get_implied_volatility("GLD")

# Create visualizations
plot_gld_chart(history)
plot_iv_surface(iv)
```

## Team

- Xuanrui Qiu
- Yaojun Liu
- Ruochen Yang

## License

MIT License
