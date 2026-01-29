# =============================================================================
# rGoldETF Complete Demo
# =============================================================================

# -----------------------------------------------------------------------------
# Step 1: Load Package
# -----------------------------------------------------------------------------
# If not installed, install dependencies first
# install.packages(c("httr", "jsonlite", "ggplot2"))

# Install from local (run in parent directory of package)
# devtools::install("rGoldETF")

# Or load development version directly
devtools::load_all(".")

# -----------------------------------------------------------------------------
# Step 2: Set API Key and Delay Configuration
# -----------------------------------------------------------------------------
# Check if API key is set, if not prompt user to set it
if (Sys.getenv("TWELVE_DATA_API_KEY") == "") {
  stop("Please set API key first: gld_set_api_key('your_api_key')\n",
       "Get free key at: https://twelvedata.com/pricing")
}

# API delay setting (free tier allows 8 calls per minute, set 8 second delay)
API_DELAY <- 8  # seconds

# Delay helper function
api_wait <- function(seconds = API_DELAY) {
  cat(sprintf("  [Waiting %d seconds to avoid API limit...]\n", seconds))
  Sys.sleep(seconds)
}

# Method 1: Use environment variable (recommended)
# Sys.setenv(TWELVE_DATA_API_KEY = "your_api_key_here")

# Method 2: Use package function
# gld_set_api_key("your_api_key_here")

# Get free API key:
# 1. Visit https://twelvedata.com/
# 2. Click "Get Free API Key"
# 3. Register account
# 4. Copy API Key from Dashboard

cat("\n")
cat("=============================================================\n")
cat("  rGoldETF Demo - Free API limited to 8 calls per minute\n")
cat("  Will wait", API_DELAY, "seconds after each API call\n")
cat("=============================================================\n")

# -----------------------------------------------------------------------------
# Step 3: Get Real-time Prices
# -----------------------------------------------------------------------------
cat("\n========== Real-time Prices ==========\n")

# Get GLD ETF real-time price
cat("\n1. Getting GLD real-time price...\n")
gld_price <- get_gld_price()
print(gld_price)
api_wait()

# Get gold spot price
cat("\n2. Getting gold spot price...\n")
gold_spot <- get_gold_spot_price()
print(gold_spot)
api_wait()

# Get other gold ETF prices
cat("\n3. Getting IAU real-time price...\n")
iau_price <- get_etf_price("IAU")  # iShares Gold Trust
print(iau_price)
api_wait()

# -----------------------------------------------------------------------------
# Step 4: Get Historical Data
# -----------------------------------------------------------------------------
cat("\n========== Historical Data ==========\n")

# Get GLD last 30 days historical data
cat("\n4. Getting GLD last 30 days historical data...\n")
gld_history <- get_gld_history(
  start_date = Sys.Date() - 30,
  end_date = Sys.Date()
)
print(head(gld_history))
api_wait()

# Get gold spot historical data
cat("\n5. Getting gold spot historical data...\n")
gold_history <- get_gold_spot_history(
  start_date = "2024-01-01",
  end_date = "2024-01-31"
)
print(head(gold_history))
api_wait()

# Get weekly data
cat("\n6. Getting GLD weekly data...\n")
gld_weekly <- get_gld_history(
  start_date = "2023-01-01",
  end_date = "2023-12-31",
  interval = "1week"
)
print(head(gld_weekly))
api_wait()

# -----------------------------------------------------------------------------
# Step 5: Calculate Technical Indicators
# -----------------------------------------------------------------------------
cat("\n========== Technical Indicators ==========\n")

# Get enough historical data for indicator calculation
cat("\n7. Getting 90 days historical data for technical indicators...\n")
history_data <- get_gld_history(
  start_date = Sys.Date() - 90,
  end_date = Sys.Date()
)
api_wait()

# Calculate single indicator (local calculation, no API call)
cat("\nCalculating SMA indicator (local calculation)...\n")
data_with_sma <- get_technical_indicators(
  history_data,
  indicators = "sma",
  periods = list(sma = 20)
)
print(tail(data_with_sma[, c("date", "close", "sma")]))

# Calculate multiple indicators (local calculation, no API call)
cat("\nCalculating multiple technical indicators (local calculation)...\n")
data_with_indicators <- get_technical_indicators(
  history_data,
  indicators = c("sma", "ema", "rsi", "macd", "bollinger"),
  periods = list(sma = 20, ema = 12, rsi = 14)
)

# View results
cat("\nLast 5 days technical indicators:\n")
print(tail(data_with_indicators[, c("date", "close", "sma", "ema", "rsi")], 5))

cat("\nMACD indicators:\n")
print(tail(data_with_indicators[, c("date", "macd", "macd_signal", "macd_histogram")], 5))

cat("\nBollinger Bands:\n")
print(tail(data_with_indicators[, c("date", "close", "bb_upper", "bb_middle", "bb_lower")], 5))

# -----------------------------------------------------------------------------
# Step 6: Visualization
# -----------------------------------------------------------------------------
cat("\n========== Visualization ==========\n")
cat("(Visualization uses local data, no API calls)\n")

# Basic price chart
cat("\nGenerating basic price chart...\n")
p1 <- plot_gld_chart(history_data, title = "GLD Price Chart")
print(p1)

# Chart with technical indicators
cat("\nGenerating chart with moving averages...\n")
p2 <- plot_gld_chart(
  data_with_indicators,
  type = "line",
  indicators = c("sma", "ema"),
  title = "GLD with Moving Averages"
)
print(p2)

# Candlestick chart
cat("\nGenerating candlestick chart...\n")
p3 <- plot_gld_chart(
  history_data,
  type = "candlestick",
  title = "GLD Candlestick Chart"
)
print(p3)

# Chart with Bollinger Bands
cat("\nGenerating Bollinger Bands chart...\n")
p4 <- plot_gld_chart(
  data_with_indicators,
  type = "line",
  indicators = c("bb_upper", "bb_middle", "bb_lower"),
  title = "GLD with Bollinger Bands"
)
print(p4)

# -----------------------------------------------------------------------------
# Step 7: Compare Multiple ETFs
# -----------------------------------------------------------------------------
cat("\n========== ETF Comparison ==========\n")

# Compare multiple gold ETFs (each ETF requires one API call)
cat("\n8-10. Comparing multiple gold ETFs (requires 3 API calls, 8 sec interval)...\n")
comparison <- compare_gold_etfs(
  symbols = c("GLD", "IAU", "SGOL"),
  start_date = Sys.Date() - 30,
  end_date = Sys.Date(),
  delay = API_DELAY
)
print(head(comparison, 20))
api_wait()

# -----------------------------------------------------------------------------
# Step 8: Search Gold-Related Symbols
# -----------------------------------------------------------------------------
cat("\n========== Search Function ==========\n")

# Search for gold-related stocks/ETFs
cat("\n11. Searching gold-related symbols...\n")
gold_symbols <- search_gold_symbols("gold")
print(head(gold_symbols, 10))
api_wait()

# -----------------------------------------------------------------------------
# Step 9: Check Market State
# -----------------------------------------------------------------------------
cat("\n========== Market State ==========\n")

# Check US stock market state
cat("\n12. Checking NYSE market state...\n")
market_state <- get_market_state("NYSE")
print(market_state)
api_wait()

# -----------------------------------------------------------------------------
# Step 10: Complete Analysis Example
# -----------------------------------------------------------------------------
cat("\n========== Complete Analysis Example ==========\n")

# Comprehensive analysis function
analyze_gold <- function() {
  # 1. Get current price
  cat("\n13. Getting current GLD price for analysis...\n")
  current_price <- get_gld_price()
  cat("Current GLD price:", current_price$price, "\n")
  cat("Today change:", current_price$change, "(", current_price$change_percent, "%)\n\n")
  api_wait()

  # 2. Get historical data and calculate indicators
  cat("14. Getting 60 days historical data...\n")
  history <- get_gld_history(
    start_date = Sys.Date() - 60,
    end_date = Sys.Date()
  )
  api_wait()

  cat("Calculating technical indicators (local calculation)...\n")
  data <- get_technical_indicators(
    history,
    indicators = c("sma", "rsi", "macd")
  )

  # 3. Get latest indicator values
  latest <- tail(data, 1)

  cat("Technical Analysis:\n")
  cat("- 20-day SMA:", round(latest$sma, 2), "\n")
  cat("- RSI(14):", round(latest$rsi, 2), "\n")
  cat("- MACD:", round(latest$macd, 4), "\n")
  cat("- MACD Signal:", round(latest$macd_signal, 4), "\n")

  # 4. Simple signal judgment
  cat("\nSignal Analysis:\n")

  if (latest$close > latest$sma) {
    cat("- Price above SMA (Bullish)\n")
  } else {
    cat("- Price below SMA (Bearish)\n")
  }

  if (latest$rsi > 70) {
    cat("- RSI overbought zone (Possible pullback)\n")
  } else if (latest$rsi < 30) {
    cat("- RSI oversold zone (Possible bounce)\n")
  } else {
    cat("- RSI neutral zone\n")
  }

  if (latest$macd > latest$macd_signal) {
    cat("- MACD bullish crossover (Buy signal)\n")
  } else {
    cat("- MACD bearish crossover (Sell signal)\n")
  }

  # 5. Generate chart
  p <- plot_gld_chart(
    data,
    type = "line",
    indicators = c("sma"),
    title = paste("GLD Analysis -", Sys.Date())
  )

  return(list(
    price = current_price,
    data = data,
    chart = p
  ))
}

# Run analysis
result <- analyze_gold()
print(result$chart)

cat("\n========== Demo Complete ==========\n")
cat("Total API calls: approximately 14\n")
cat("For more information see package documentation: ?rGoldETF\n")
