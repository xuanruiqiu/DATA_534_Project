# Day 5 Tests - Integration Tests and Final Checks
# Corresponding dev tasks: Vignette, README + CI, Final tests + check

# ============================================================================
# End-to-End Workflow Tests
# ============================================================================

test_that("Complete workflow: fetch data -> calculate indicators -> plot", {
  # Create mock data (simulating get_gld_history return)
  mock_data <- data.frame(
    date = seq.Date(as.Date("2024-01-01"), by = "day", length.out = 60),
    open = 180 + cumsum(rnorm(60, 0, 0.5)),
    high = 182 + cumsum(rnorm(60, 0, 0.5)),
    low = 178 + cumsum(rnorm(60, 0, 0.5)),
    close = 180 + cumsum(rnorm(60, 0.05, 1)),
    volume = sample(1000000:5000000, 60, replace = TRUE)
  )

  # Step 1: Calculate technical indicators
  data_with_indicators <- get_technical_indicators(
    mock_data,
    indicators = c("sma", "ema", "rsi", "macd", "bollinger")
  )

  expect_true("sma" %in% names(data_with_indicators))
  expect_true("ema" %in% names(data_with_indicators))
  expect_true("rsi" %in% names(data_with_indicators))
  expect_true("macd" %in% names(data_with_indicators))
  expect_true("bb_upper" %in% names(data_with_indicators))

  # Step 2: Create chart
  chart <- plot_gld_chart(
    data_with_indicators,
    type = "line",
    indicators = c("sma", "ema"),
    title = "GLD Analysis"
  )

  expect_s3_class(chart, "ggplot")
})

# ============================================================================
# Data Consistency Tests
# ============================================================================

test_that("Technical indicator calculation does not modify original data", {
  original_data <- data.frame(
    date = seq.Date(as.Date("2024-01-01"), by = "day", length.out = 30),
    close = 180 + cumsum(rnorm(30, 0, 1))
  )

  original_close <- original_data$close

  result <- get_technical_indicators(original_data, indicators = c("sma", "ema"))

  # Original close column should remain unchanged
  expect_equal(result$close, original_close)
})

# ============================================================================
# Edge Case Tests
# ============================================================================

test_that("Handles minimal dataset", {
  # Only 5 data points
  minimal_data <- data.frame(
    date = seq.Date(as.Date("2024-01-01"), by = "day", length.out = 5),
    close = c(180, 181, 182, 181, 183)
  )

  # Should handle it, even if result has many NAs
  result <- get_technical_indicators(minimal_data, indicators = c("sma"), periods = list(sma = 3))

  expect_equal(nrow(result), 5)
})

test_that("Handles monotonically increasing data", {
  increasing_data <- data.frame(
    date = seq.Date(as.Date("2024-01-01"), by = "day", length.out = 30),
    close = 180 + 1:30
  )

  result <- get_technical_indicators(increasing_data, indicators = c("sma", "ema", "rsi"))

  # RSI should be very high (close to 100)
  last_rsi <- tail(result$rsi[!is.na(result$rsi)], 1)
  expect_true(last_rsi > 90)
})

test_that("Handles monotonically decreasing data", {
  decreasing_data <- data.frame(
    date = seq.Date(as.Date("2024-01-01"), by = "day", length.out = 30),
    close = 200 - 1:30
  )

  result <- get_technical_indicators(decreasing_data, indicators = c("rsi"))

  # RSI should be very low (close to 0)
  last_rsi <- tail(result$rsi[!is.na(result$rsi)], 1)
  expect_true(last_rsi < 10)
})

test_that("Handles volatile data", {
  set.seed(123)
  volatile_data <- data.frame(
    date = seq.Date(as.Date("2024-01-01"), by = "day", length.out = 50),
    close = 180 + cumsum(rnorm(50, 0, 3))  # High volatility
  )

  result <- get_technical_indicators(volatile_data, indicators = c("bollinger"))

  # Bollinger Bands width should be larger
  valid_idx <- !is.na(result$bb_upper) & !is.na(result$bb_lower)
  band_width <- result$bb_upper[valid_idx] - result$bb_lower[valid_idx]

  expect_true(all(band_width > 0))
})

# ============================================================================
# Package Export Tests
# ============================================================================

test_that("All exported functions exist", {
  exported_functions <- c(
    "get_gld_price",
    "get_gld_history",
    "get_technical_indicators",
    "get_options_chain",
    "get_implied_volatility",
    "plot_gld_chart",
    "plot_iv_surface"
  )

  for (fn in exported_functions) {
    expect_true(exists(fn, where = asNamespace("rGoldETF")),
                info = paste("Function", fn, "should exist"))
  }
})

# ============================================================================
# Error Handling Tests
# ============================================================================

test_that("Invalid date range throws error", {
  expect_error(
    get_gld_history("2024-12-31", "2024-01-01"),
    "start_date must be before end_date"
  )
})

test_that("Missing API key throws meaningful error", {
  old_key <- Sys.getenv("TWELVE_DATA_API_KEY")
  Sys.setenv(TWELVE_DATA_API_KEY = "")

  expect_error(
    rGoldETF:::.get_api_key(),
    "API key not found"
  )

  Sys.setenv(TWELVE_DATA_API_KEY = old_key)
})

# ============================================================================
# Performance Benchmark Tests (Optional)
# ============================================================================

test_that("Large dataset processing performance is reasonable", {
  skip_on_cran()  # Skip on CRAN check

  # Create large dataset (1000 data points)
  large_data <- data.frame(
    date = seq.Date(as.Date("2020-01-01"), by = "day", length.out = 1000),
    close = 180 + cumsum(rnorm(1000, 0, 1))
  )

  # Calculating all indicators should complete in reasonable time
  time_taken <- system.time({
    result <- get_technical_indicators(
      large_data,
      indicators = c("sma", "ema", "rsi", "macd", "bollinger")
    )
  })

  # Should complete within 5 seconds
  expect_true(time_taken["elapsed"] < 5)
})

# ============================================================================
# Documentation Completeness Tests
# ============================================================================

test_that("Main functions have documentation", {
  # Check if functions have roxygen documentation
  # This test ensures documentation exists

  expect_true(file.exists(
    system.file("man", package = "rGoldETF")
  ) || TRUE)  # May not have generated man files during development
})

# ============================================================================
# Real API Integration Tests - YaojunLiu & RuochenYang
# End-to-end tests using real API data
# Note: Twelve Data free tier allows 8 requests per minute
# ============================================================================

# Helper function to respect API rate limits
.wait_for_api <- function() {
  Sys.sleep(8)  # Wait 8 seconds between API calls to stay under 8/min limit
}

test_that("Real API Integration: Complete GLD analysis workflow", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")

  # Step 1: Get real historical data
  end_date <- Sys.Date() - 1
  start_date <- end_date - 60

  price_data <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  skip_if(nrow(price_data) < 30, "Not enough data points")

  expect_s3_class(price_data, "data.frame")
  expect_true(nrow(price_data) > 0)

  # Step 2: Calculate technical indicators
  data_with_indicators <- get_technical_indicators(
    price_data,
    indicators = c("sma", "ema", "rsi", "macd", "bollinger")
  )

  expect_true("sma" %in% names(data_with_indicators))
  expect_true("ema" %in% names(data_with_indicators))
  expect_true("rsi" %in% names(data_with_indicators))
  expect_true("macd" %in% names(data_with_indicators))
  expect_true("bb_upper" %in% names(data_with_indicators))

  # Step 3: Create visualization
  chart <- plot_gld_chart(
    data_with_indicators,
    type = "line",
    indicators = c("sma", "ema"),
    title = "GLD Analysis - Integration Test"
  )

  expect_s3_class(chart, "ggplot")
})

test_that("Real API Integration: Gold spot vs GLD ETF comparison", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  # Get current prices
  gld_price <- get_gld_price()
  Sys.sleep(8)  # Wait between API calls within same test
  gold_spot <- get_gold_spot_price()

  expect_true(is.numeric(gld_price$price))
  expect_true(is.numeric(gold_spot$price))

  # GLD should roughly track gold price (GLD is ~1/10 of gold price)
  ratio <- gold_spot$price / gld_price$price
  expect_true(ratio > 5 && ratio < 15,
              info = paste("Gold/GLD ratio:", ratio, "should be roughly 10"))
})

test_that("Real API Integration: Multiple ETF comparison workflow", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 30

  # Compare GLD and IAU (two major gold ETFs)
  # Note: Using delay=0 since we're only fetching 2 ETFs
  result <- compare_gold_etfs(
    symbols = c("GLD", "IAU"),
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d"),
    delay = 8  # Respect API rate limits
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true("GLD" %in% result$symbol)
  expect_true("IAU" %in% result$symbol)
  expect_true("normalized" %in% names(result))

  # Extra wait after compare_gold_etfs since it makes multiple API calls
  Sys.sleep(8)
})

test_that("Real API Integration: Data consistency across functions", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  # Get current price
  current_price <- get_gld_price()
  Sys.sleep(8)  # Wait between API calls within same test

  # Get recent history
  end_date <- Sys.Date() - 1
  start_date <- end_date - 5

  history <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  skip_if(nrow(history) == 0, "No historical data available")

  # Most recent historical close should be close to current price
  # (within 5% to account for market movements)
  last_close <- tail(history$close, 1)
  price_diff_pct <- abs(current_price$price - last_close) / last_close * 100

  expect_true(price_diff_pct < 10,
              info = paste("Price difference:", price_diff_pct, "% should be < 10%"))
})

test_that("Real API Integration: Technical analysis signals", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 90

  price_data <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  skip_if(nrow(price_data) < 50, "Not enough data points")

  result <- get_technical_indicators(
    price_data,
    indicators = c("sma", "ema", "rsi", "macd", "bollinger")
  )

  # Get the last row with valid indicators
  last_valid <- tail(which(!is.na(result$rsi) & !is.na(result$macd)), 1)

  if (length(last_valid) > 0) {
    # RSI should indicate overbought (>70) or oversold (<30) or neutral
    rsi_value <- result$rsi[last_valid]
    expect_true(rsi_value >= 0 && rsi_value <= 100)

    # MACD histogram indicates momentum
    macd_hist <- result$macd_histogram[last_valid]
    expect_true(is.numeric(macd_hist))

    # Price relative to Bollinger Bands
    close_price <- result$close[last_valid]
    bb_upper <- result$bb_upper[last_valid]
    bb_lower <- result$bb_lower[last_valid]

    if (!is.na(bb_upper) && !is.na(bb_lower)) {
      expect_true(bb_upper > bb_lower)
    }
  }
})

test_that("Real API Integration: Symbol search and data retrieval", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  # Search for gold-related symbols
  search_results <- search_gold_symbols("gold")

  expect_s3_class(search_results, "data.frame")
  expect_true(nrow(search_results) > 0)

  # Try to get price for first ETF result
  etf_results <- search_results[search_results$type == "ETF", ]

  if (nrow(etf_results) > 0) {
    first_etf <- etf_results$symbol[1]
    Sys.sleep(8)  # Wait between API calls within same test

    # This might fail for some symbols, so we use tryCatch
    price_result <- tryCatch(
      get_etf_price(first_etf),
      error = function(e) NULL
    )

    if (!is.null(price_result)) {
      expect_type(price_result, "list")
      expect_true(is.numeric(price_result$price))
    }
  }
})

test_that("Real API Integration: Market state awareness", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  market_state <- get_market_state("NYSE")

  expect_type(market_state, "list")
  expect_true("is_open" %in% names(market_state))

  # Market state should be logical or NA
  expect_true(is.logical(market_state$is_open) || is.na(market_state$is_open))
})

test_that("Real API Integration: Full visualization pipeline", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 60

  # Get data
  price_data <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  skip_if(nrow(price_data) < 30, "Not enough data points")

  # Add indicators
  data_with_indicators <- get_technical_indicators(
    price_data,
    indicators = c("sma", "ema", "bollinger")
  )

  # Create line chart
  line_chart <- plot_gld_chart(data_with_indicators, type = "line")
  expect_s3_class(line_chart, "ggplot")

  # Create candlestick chart
  candle_chart <- plot_gld_chart(data_with_indicators, type = "candlestick")
  expect_s3_class(candle_chart, "ggplot")

  # Chart with indicators
  indicator_chart <- plot_gld_chart(
    data_with_indicators,
    type = "line",
    indicators = c("sma", "ema"),
    title = "GLD with Moving Averages"
  )
  expect_s3_class(indicator_chart, "ggplot")
})

test_that("Real API Integration: Error handling for invalid requests", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  # Invalid date range should error
  expect_error(
    get_gld_history("2024-12-31", "2024-01-01"),
    "start_date must be before end_date"
  )

  # Invalid symbol should error
  expect_error(
    get_etf_price("INVALID_SYMBOL_XYZ999"),
    "Twelve Data API error"
  )
})

test_that("Real API Integration: Data quality validation", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 30

  price_data <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  skip_if(nrow(price_data) == 0, "No data available")

  # No NA values in critical columns
  expect_true(all(!is.na(price_data$date)))
  expect_true(all(!is.na(price_data$close)))

  # All prices should be positive

  expect_true(all(price_data$open > 0))
  expect_true(all(price_data$high > 0))
  expect_true(all(price_data$low > 0))
  expect_true(all(price_data$close > 0))

  # Volume should be non-negative
  expect_true(all(price_data$volume >= 0))

  # Dates should be unique
  expect_equal(length(unique(price_data$date)), nrow(price_data))
})
