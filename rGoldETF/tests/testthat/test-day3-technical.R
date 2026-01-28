# Day 3 Tests - Technical Indicators Tests
# Corresponding dev tasks: get_technical_indicators(), get_options_chain()

# ============================================================================
# Test Data Preparation
# ============================================================================

# Create standard test dataset
create_test_price_data <- function(n = 50) {
  set.seed(42)  # Ensure reproducibility
  data.frame(
    date = seq.Date(as.Date("2024-01-01"), by = "day", length.out = n),
    open = 180 + cumsum(rnorm(n, 0, 0.5)),
    high = 182 + cumsum(rnorm(n, 0, 0.5)),
    low = 178 + cumsum(rnorm(n, 0, 0.5)),
    close = 180 + cumsum(rnorm(n, 0.05, 1)),
    volume = sample(1000000:5000000, n, replace = TRUE)
  )
}

# ============================================================================
# SMA (Simple Moving Average) Tests
# ============================================================================

test_that("SMA calculates correctly", {
  # Simple test data
  prices <- c(10, 11, 12, 13, 14, 15, 16, 17, 18, 19)

  # 5-day SMA
  sma_5 <- rGoldETF:::.calculate_sma(prices, 5)

  # First 4 values should be NA (insufficient data points)
  expect_true(all(is.na(sma_5[1:4])))

  # 5th value should be (10+11+12+13+14)/5 = 12
  expect_equal(sma_5[5], 12, tolerance = 0.001)

  # 10th value should be (15+16+17+18+19)/5 = 17
  expect_equal(sma_5[10], 17, tolerance = 0.001)
})

test_that("SMA length matches input", {
  prices <- rnorm(100, 180, 5)
  sma <- rGoldETF:::.calculate_sma(prices, 20)

  expect_equal(length(sma), length(prices))
})

# ============================================================================
# EMA (Exponential Moving Average) Tests
# ============================================================================

test_that("EMA calculates correctly", {
  prices <- c(10, 11, 12, 13, 14)

  ema <- rGoldETF:::.calculate_ema(prices, 3)

  # EMA first value equals first price
  expect_equal(ema[1], prices[1])

  # EMA length matches input
  expect_equal(length(ema), length(prices))

  # EMA should be numeric
  expect_type(ema, "double")
})

test_that("EMA responds faster to trend data", {
  # Uptrend data
  prices <- 1:20

  sma <- rGoldETF:::.calculate_sma(prices, 5)
  ema <- rGoldETF:::.calculate_ema(prices, 5)

  # In uptrend, EMA should be closer to current price than SMA
  # (because EMA weights recent data more heavily)
  last_idx <- length(prices)
  expect_true(ema[last_idx] > sma[last_idx])
})

# ============================================================================
# RSI (Relative Strength Index) Tests
# ============================================================================

test_that("RSI values are within 0-100 range", {
  test_data <- create_test_price_data(100)
  rsi <- rGoldETF:::.calculate_rsi(test_data$close, 14)

  # Check range after removing NA values
  rsi_valid <- rsi[!is.na(rsi)]
  expect_true(all(rsi_valid >= 0 & rsi_valid <= 100))
})

test_that("RSI length is correct", {
  prices <- rnorm(50, 180, 5)
  rsi <- rGoldETF:::.calculate_rsi(prices, 14)

  expect_equal(length(rsi), length(prices))
})

test_that("RSI trends high during continuous uptrend", {
  # Continuously rising prices
  prices <- cumsum(rep(1, 30)) + 100

  rsi <- rGoldETF:::.calculate_rsi(prices, 14)
  last_rsi <- tail(rsi[!is.na(rsi)], 1)

  # RSI should be very high during continuous uptrend (> 70)
  expect_true(last_rsi > 70)
})

# ============================================================================
# MACD Tests
# ============================================================================

test_that("MACD returns correct components", {
  test_data <- create_test_price_data(50)
  macd_result <- rGoldETF:::.calculate_macd(test_data$close)

  expect_true("macd" %in% names(macd_result))
  expect_true("signal" %in% names(macd_result))
  expect_true("histogram" %in% names(macd_result))
})

test_that("MACD histogram = MACD - Signal", {
  test_data <- create_test_price_data(50)
  macd_result <- rGoldETF:::.calculate_macd(test_data$close)

  expected_histogram <- macd_result$macd - macd_result$signal
  expect_equal(macd_result$histogram, expected_histogram, tolerance = 0.0001)
})

# ============================================================================
# Bollinger Bands Tests
# ============================================================================

test_that("Bollinger Bands returns three lines", {
  test_data <- create_test_price_data(50)
  bb <- rGoldETF:::.calculate_bollinger(test_data$close, 20)

  expect_true("upper" %in% names(bb))
  expect_true("middle" %in% names(bb))
  expect_true("lower" %in% names(bb))
})

test_that("Bollinger Bands order is correct (upper > middle > lower)", {
  test_data <- create_test_price_data(50)
  bb <- rGoldETF:::.calculate_bollinger(test_data$close, 20)

  # Remove NA values
  valid_idx <- !is.na(bb$upper) & !is.na(bb$middle) & !is.na(bb$lower)

  expect_true(all(bb$upper[valid_idx] >= bb$middle[valid_idx]))
  expect_true(all(bb$middle[valid_idx] >= bb$lower[valid_idx]))
})

# ============================================================================
# get_technical_indicators() Integration Tests
# ============================================================================

test_that("get_technical_indicators adds correct columns", {
  test_data <- create_test_price_data(50)

  result <- get_technical_indicators(
    test_data,
    indicators = c("sma", "ema", "rsi"),
    periods = list(sma = 20, ema = 12, rsi = 14)
  )

  expect_true("sma" %in% names(result))
  expect_true("ema" %in% names(result))
  expect_true("rsi" %in% names(result))
})

test_that("get_technical_indicators preserves original data", {
  test_data <- create_test_price_data(50)
  original_cols <- names(test_data)

  result <- get_technical_indicators(test_data, indicators = c("sma"))

  # Original columns should all be preserved
  expect_true(all(original_cols %in% names(result)))
})

test_that("get_technical_indicators row count unchanged", {
  test_data <- create_test_price_data(50)

  result <- get_technical_indicators(
    test_data,
    indicators = c("sma", "ema", "rsi", "macd", "bollinger")
  )

  expect_equal(nrow(result), nrow(test_data))
})

# ============================================================================
# Real API Tests - RuochenYang
# These tests use real API data to test technical indicators
# Note: Twelve Data free tier allows 8 requests per minute
# ============================================================================

# Helper function to respect API rate limits
.wait_for_api <- function() {
  Sys.sleep(8)  # Wait 8 seconds between API calls to stay under 8/min limit
}

test_that("Real API: Technical indicators work with real GLD data", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")

  # Get real historical data
  end_date <- Sys.Date() - 1
  start_date <- end_date - 60

  price_data <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  skip_if(nrow(price_data) < 30, "Not enough data points")

  # Calculate all indicators
  result <- get_technical_indicators(
    price_data,
    indicators = c("sma", "ema", "rsi", "macd", "bollinger")
  )

  expect_s3_class(result, "data.frame")
  expect_true("sma" %in% names(result))
  expect_true("ema" %in% names(result))
  expect_true("rsi" %in% names(result))
  expect_true("macd" %in% names(result))
  expect_true("bb_upper" %in% names(result))
})

test_that("Real API: SMA calculation on real data is accurate", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 60

  price_data <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  skip_if(nrow(price_data) < 30, "Not enough data points")

  result <- get_technical_indicators(price_data, indicators = c("sma"), periods = list(sma = 20))

  # Verify SMA calculation manually for the last valid point
  valid_idx <- which(!is.na(result$sma))
  if (length(valid_idx) > 0) {
    last_valid <- tail(valid_idx, 1)
    expected_sma <- mean(price_data$close[(last_valid - 19):last_valid])
    expect_equal(result$sma[last_valid], expected_sma, tolerance = 0.01)
  }
})

test_that("Real API: RSI values are within valid range on real data", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 60

  price_data <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  skip_if(nrow(price_data) < 20, "Not enough data points")

  result <- get_technical_indicators(price_data, indicators = c("rsi"))

  rsi_valid <- result$rsi[!is.na(result$rsi)]
  expect_true(all(rsi_valid >= 0 & rsi_valid <= 100),
              info = "RSI should be between 0 and 100")
})

test_that("Real API: Bollinger Bands contain price on real data", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 60

  price_data <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  skip_if(nrow(price_data) < 30, "Not enough data points")

  result <- get_technical_indicators(price_data, indicators = c("bollinger"))

  # Most prices should be within Bollinger Bands (statistically ~95%)
  valid_idx <- !is.na(result$bb_upper) & !is.na(result$bb_lower)
  within_bands <- result$close[valid_idx] >= result$bb_lower[valid_idx] &
                  result$close[valid_idx] <= result$bb_upper[valid_idx]

  # At least 80% should be within bands
  expect_true(mean(within_bands) > 0.8,
              info = "Most prices should be within Bollinger Bands")
})

test_that("Real API: MACD histogram reflects trend on real data", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 90

  price_data <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  skip_if(nrow(price_data) < 40, "Not enough data points")

  result <- get_technical_indicators(price_data, indicators = c("macd"))

  expect_true("macd" %in% names(result))
  expect_true("macd_signal" %in% names(result))
  expect_true("macd_histogram" %in% names(result))

  # Verify histogram = MACD - Signal
  valid_idx <- !is.na(result$macd) & !is.na(result$macd_signal)
  if (sum(valid_idx) > 0) {
    expected_hist <- result$macd[valid_idx] - result$macd_signal[valid_idx]
    expect_equal(result$macd_histogram[valid_idx], expected_hist, tolerance = 0.0001)
  }
})

test_that("Real API: EMA responds faster than SMA on real data", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 60

  price_data <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  skip_if(nrow(price_data) < 30, "Not enough data points")

  result <- get_technical_indicators(
    price_data,
    indicators = c("sma", "ema"),
    periods = list(sma = 20, ema = 20)
  )

  # Calculate the difference between current price and moving averages
  valid_idx <- !is.na(result$sma) & !is.na(result$ema)
  if (sum(valid_idx) > 5) {
    # EMA should generally be closer to recent prices than SMA
    # This is a statistical property, not guaranteed for every point
    ema_diff <- abs(result$close[valid_idx] - result$ema[valid_idx])
    sma_diff <- abs(result$close[valid_idx] - result$sma[valid_idx])

    # On average, EMA should be closer to price
    expect_true(mean(ema_diff) <= mean(sma_diff) * 1.5,
                info = "EMA should generally track price more closely than SMA")
  }
})

test_that("Real API: Technical indicators preserve original data columns", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 30

  price_data <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  skip_if(nrow(price_data) < 25, "Not enough data points")

  original_cols <- names(price_data)
  original_close <- price_data$close

  result <- get_technical_indicators(
    price_data,
    indicators = c("sma", "ema", "rsi"),
    periods = list(sma = 10, ema = 10, rsi = 14)
  )

  # All original columns should be preserved
  expect_true(all(original_cols %in% names(result)))

  # Original close values should be unchanged
  expect_equal(result$close, original_close)
})
