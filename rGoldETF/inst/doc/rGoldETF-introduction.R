## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(

  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5,
  eval = FALSE
)

## ----installation-------------------------------------------------------------
# # install.packages("devtools")
# devtools::install_github("xuanruiqiu/DATA_534_Project", subdir = "rGoldETF")

## ----setup--------------------------------------------------------------------
# library(rGoldETF)
# 
# # Method 1: Set environment variable (recommended)
# Sys.setenv(TWELVE_DATA_API_KEY = "your_api_key_here")
# 
# # Method 2: Use the package helper function
# gld_set_api_key("your_api_key_here")

## ----gld-price----------------------------------------------------------------
# # Get current GLD price
# gld_price <- get_gld_price()
# print(gld_price)

## ----gold-spot----------------------------------------------------------------
# # Get gold spot price
# gold_spot <- get_gold_spot_price()
# print(gold_spot)

## ----other-etf----------------------------------------------------------------
# # Get price for any ETF
# iau_price <- get_etf_price("IAU")  # iShares Gold Trust
# print(iau_price)

## ----gld-history--------------------------------------------------------------
# # Get last 30 days of GLD data
# gld_history <- get_gld_history(
#   start_date = Sys.Date() - 30,
#   end_date = Sys.Date()
# )
# head(gld_history)

## ----intervals----------------------------------------------------------------
# # Weekly data
# gld_weekly <- get_gld_history(
#   start_date = "2023-01-01",
#   end_date = "2023-12-31",
#   interval = "1week"
# )
# 
# # Monthly data
# gld_monthly <- get_gld_history(
#   start_date = "2022-01-01",
#   end_date = "2023-12-31",
#   interval = "1month"
# )

## ----gold-spot-history--------------------------------------------------------
# # Get gold spot price history
# gold_history <- get_gold_spot_history(
#   start_date = "2024-01-01",
#   end_date = "2024-01-31"
# )
# head(gold_history)

## ----sma-ema------------------------------------------------------------------
# # Get historical data first
# history_data <- get_gld_history(
#   start_date = Sys.Date() - 90,
#   end_date = Sys.Date()
# )
# 
# # Calculate SMA and EMA
# data_with_ma <- get_technical_indicators(
#   history_data,
#   indicators = c("sma", "ema"),
#   periods = list(sma = 20, ema = 12)
# )
# 
# # View results
# tail(data_with_ma[, c("date", "close", "sma", "ema")], 10)

## ----rsi----------------------------------------------------------------------
# # Calculate RSI
# data_with_rsi <- get_technical_indicators(
#   history_data,
#   indicators = "rsi",
#   periods = list(rsi = 14)
# )
# 
# # View RSI values
# tail(data_with_rsi[, c("date", "close", "rsi")], 10)

## ----macd---------------------------------------------------------------------
# # Calculate MACD
# data_with_macd <- get_technical_indicators(
#   history_data,
#   indicators = "macd"
# )
# 
# # View MACD components
# tail(data_with_macd[, c("date", "macd", "macd_signal", "macd_histogram")], 10)

## ----bollinger----------------------------------------------------------------
# # Calculate Bollinger Bands
# data_with_bb <- get_technical_indicators(
#   history_data,
#   indicators = "bollinger",
#   periods = list(sma = 20)
# )
# 
# # View Bollinger Bands
# tail(data_with_bb[, c("date", "close", "bb_upper", "bb_middle", "bb_lower")], 10)

## ----all-indicators-----------------------------------------------------------
# # Calculate all indicators at once
# data_full <- get_technical_indicators(
#   history_data,
#   indicators = c("sma", "ema", "rsi", "macd", "bollinger"),
#   periods = list(sma = 20, ema = 12, rsi = 14)
# )

## ----plot-line, eval=TRUE, echo=TRUE------------------------------------------
# Create sample data for demonstration
set.seed(42)
n <- 60
demo_data <- data.frame(
  date = seq(Sys.Date() - n + 1, Sys.Date(), by = "day"),
  open = cumsum(rnorm(n, 0.1, 1)) + 180,
  high = cumsum(rnorm(n, 0.15, 1)) + 182,
  low = cumsum(rnorm(n, 0.05, 1)) + 178,
  close = cumsum(rnorm(n, 0.1, 1)) + 180,
  volume = abs(rnorm(n, 5000000, 1000000))
)
demo_data$high <- pmax(demo_data$high, demo_data$open, demo_data$close)
demo_data$low <- pmin(demo_data$low, demo_data$open, demo_data$close)

library(ggplot2)

# Basic line chart
p1 <- ggplot(demo_data, aes(x = date, y = close)) +
  geom_line(color = "steelblue", linewidth = 0.8) +
  labs(title = "GLD Price Chart", x = "Date", y = "Price (USD)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))
print(p1)

## ----plot-ma, eval=TRUE, echo=TRUE--------------------------------------------
# Add moving averages to demo data
demo_data$sma <- stats::filter(demo_data$close, rep(1/20, 20), sides = 1)
alpha <- 2 / (12 + 1)
demo_data$ema <- demo_data$close[1]
for (i in 2:nrow(demo_data)) {
  demo_data$ema[i] <- alpha * demo_data$close[i] + (1 - alpha) * demo_data$ema[i-1]
}

# Chart with indicators
p2 <- ggplot(demo_data, aes(x = date)) +
  geom_line(aes(y = close), color = "steelblue", linewidth = 0.8) +
  geom_line(aes(y = sma), color = "orange", linewidth = 0.6, na.rm = TRUE) +
  geom_line(aes(y = ema), color = "purple", linewidth = 0.6, na.rm = TRUE) +
  labs(
    title = "GLD with Moving Averages",
    subtitle = "Orange: 20-day SMA, Purple: 12-day EMA",
    x = "Date",
    y = "Price (USD)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))
print(p2)

## ----plot-candlestick, eval=TRUE, echo=TRUE-----------------------------------
# Candlestick chart (last 30 days for clarity)
candle_data <- tail(demo_data, 30)
candle_data$direction <- ifelse(candle_data$close >= candle_data$open, "up", "down")

p3 <- ggplot(candle_data, aes(x = date)) +
  geom_segment(aes(xend = date, y = low, yend = high), color = "black") +
  geom_rect(aes(
    xmin = date - 0.3,
    xmax = date + 0.3,
    ymin = pmin(open, close),
    ymax = pmax(open, close),
    fill = direction
  )) +
  scale_fill_manual(values = c("up" = "green", "down" = "red"), guide = "none") +
  labs(title = "GLD Candlestick Chart", x = "Date", y = "Price (USD)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))
print(p3)

## ----plot-bollinger, eval=TRUE, echo=TRUE-------------------------------------
# Add Bollinger Bands
demo_data$bb_middle <- demo_data$sma
sd_val <- sd(demo_data$close, na.rm = TRUE)
demo_data$bb_upper <- demo_data$bb_middle + 2 * sd_val
demo_data$bb_lower <- demo_data$bb_middle - 2 * sd_val

p4 <- ggplot(demo_data, aes(x = date)) +
  geom_ribbon(aes(ymin = bb_lower, ymax = bb_upper),
              fill = "lightblue", alpha = 0.3, na.rm = TRUE) +
  geom_line(aes(y = close), color = "steelblue", linewidth = 0.8) +
  geom_line(aes(y = bb_middle), color = "orange", linetype = "dashed", na.rm = TRUE) +
  geom_line(aes(y = bb_upper), color = "gray50", linetype = "dashed", na.rm = TRUE) +
  geom_line(aes(y = bb_lower), color = "gray50", linetype = "dashed", na.rm = TRUE) +
  labs(
    title = "GLD with Bollinger Bands",
    subtitle = "20-day SMA with 2 standard deviation bands",
    x = "Date",
    y = "Price (USD)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))
print(p4)

## ----compare-etfs-------------------------------------------------------------
# # Compare GLD, IAU, and SGOL
# comparison <- compare_gold_etfs(
#   symbols = c("GLD", "IAU", "SGOL"),
#   start_date = Sys.Date() - 30,
#   end_date = Sys.Date(),
#   delay = 8  # Respect API rate limits
# )
# head(comparison, 15)

## ----plot-comparison, eval=TRUE, echo=TRUE------------------------------------
# Create sample comparison data
set.seed(123)
dates <- seq(Sys.Date() - 29, Sys.Date(), by = "day")
comparison_demo <- data.frame(
  date = rep(dates, 3),
  symbol = rep(c("GLD", "IAU", "SGOL"), each = 30),
  normalized = c(
    100 + cumsum(rnorm(30, 0.1, 0.5)),
    100 + cumsum(rnorm(30, 0.08, 0.45)),
    100 + cumsum(rnorm(30, 0.12, 0.55))
  )
)

p5 <- ggplot(comparison_demo, aes(x = date, y = normalized, color = symbol)) +
  geom_line(linewidth = 1) +
  scale_color_manual(values = c("GLD" = "gold", "IAU" = "steelblue", "SGOL" = "darkgreen")) +
  labs(
    title = "Gold ETF Comparison",
    subtitle = "Normalized to 100 at start date",
    x = "Date",
    y = "Normalized Price",
    color = "ETF"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    legend.position = "bottom"
  )
print(p5)

## ----search-------------------------------------------------------------------
# # Search for gold-related symbols
# gold_symbols <- search_gold_symbols("gold")
# head(gold_symbols, 10)

## ----market-state-------------------------------------------------------------
# # Check if NYSE is open
# market_state <- get_market_state("NYSE")
# print(market_state)

## ----complete-analysis--------------------------------------------------------
# # 1. Get current price
# current <- get_gld_price()
# cat("Current GLD Price:", current$price, "\n")
# cat("Today's Change:", current$change, "(", current$change_percent, "%)\n\n")
# 
# Sys.sleep(8)  # Respect rate limits
# 
# # 2. Get historical data
# history <- get_gld_history(
#   start_date = Sys.Date() - 60,
#   end_date = Sys.Date()
# )
# 
# # 3. Calculate technical indicators (no API call)
# analysis_data <- get_technical_indicators(
#   history,
#   indicators = c("sma", "ema", "rsi", "macd", "bollinger")
# )
# 
# # 4. Get latest values
# latest <- tail(analysis_data, 1)
# 
# cat("Technical Analysis Summary:\n")
# cat("- 20-day SMA:", round(latest$sma, 2), "\n")
# cat("- 12-day EMA:", round(latest$ema, 2), "\n")
# cat("- RSI(14):", round(latest$rsi, 2), "\n")
# cat("- MACD:", round(latest$macd, 4), "\n")
# 
# # 5. Generate signals
# cat("\nSignal Analysis:\n")
# if (latest$close > latest$sma) {
#   cat("- Price above SMA: BULLISH\n")
# } else {
#   cat("- Price below SMA: BEARISH\n")
# }
# 
# if (latest$rsi > 70) {
#   cat("- RSI > 70: OVERBOUGHT\n")
# } else if (latest$rsi < 30) {
#   cat("- RSI < 30: OVERSOLD\n")
# } else {
#   cat("- RSI in neutral zone\n")
# }
# 
# # 6. Create visualization
# chart <- plot_gld_chart(
#   analysis_data,
#   type = "line",
#   indicators = c("sma", "ema"),
#   title = paste("GLD Analysis -", Sys.Date())
# )
# print(chart)

## ----error-handling-----------------------------------------------------------
# # Missing API key
# tryCatch({
#   Sys.setenv(TWELVE_DATA_API_KEY = "")
#   get_gld_price()
# }, error = function(e) {
#   cat("Error:", e$message, "\n")
# })
# 
# # Invalid date range
# tryCatch({
#   get_gld_history(
#     start_date = "2024-01-31",
#     end_date = "2024-01-01"  # End before start
#   )
# }, error = function(e) {
#   cat("Error:", e$message, "\n")
# })

## ----session-info, eval=TRUE--------------------------------------------------
sessionInfo()

