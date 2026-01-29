# Day 4 Tests - Options and Visualization Tests
# Corresponding dev tasks: get_implied_volatility(), plot_gld_chart(), plot_iv_surface()

# Load ggplot2 for visualization tests (not imported in NAMESPACE)
library(ggplot2)

# ============================================================================
# Mock Data
# ============================================================================

# Price history mock data
mock_price_history <- data.frame(
  date = seq.Date(as.Date("2024-01-01"), by = "day", length.out = 60),
  open = 180 + cumsum(rnorm(60, 0, 0.5)),
  high = 182 + cumsum(rnorm(60, 0, 0.5)),
  low = 178 + cumsum(rnorm(60, 0, 0.5)),
  close = 180 + cumsum(rnorm(60, 0.05, 1)),
  volume = sample(1000000:5000000, 60, replace = TRUE)
)

# Implied volatility mock data (for visualization testing only)
mock_iv_data <- data.frame(
  strike = rep(seq(170, 200, by = 5), 4),
  expiration = rep(c("2024-02-16", "2024-03-15", "2024-04-19", "2024-06-21"), each = 7),
  call_iv = runif(28, 0.12, 0.30),
  put_iv = runif(28, 0.12, 0.30),
  days_to_expiry = rep(c(30, 60, 90, 150), each = 7)
)

# ============================================================================
# Options Functions Tests (Paid Feature)
# ============================================================================

test_that("get_options_chain returns error for free tier", {
  expect_error(
    rGoldETF:::get_options_chain("GLD"),
    "paid Twelve Data subscription"
  )
})

test_that("get_implied_volatility returns error for free tier", {
  expect_error(
    rGoldETF:::get_implied_volatility("GLD"),
    "paid Twelve Data subscription"
  )
})

# ============================================================================
# Visualization Tests - plot_gld_chart()
# ============================================================================

test_that("plot_gld_chart returns ggplot object", {
  p <- rGoldETF:::plot_gld_chart(mock_price_history)

  expect_s3_class(p, "ggplot")
})

test_that("plot_gld_chart supports line type", {
  p <- rGoldETF:::plot_gld_chart(mock_price_history, type = "line")

  expect_s3_class(p, "ggplot")
})

test_that("plot_gld_chart supports candlestick type", {
  p <- rGoldETF:::plot_gld_chart(mock_price_history, type = "candlestick")

  expect_s3_class(p, "ggplot")
})

test_that("plot_gld_chart can add indicators", {
  # First calculate indicators
  data_with_indicators <- get_technical_indicators(
    mock_price_history,
    indicators = c("sma", "ema")
  )

  p <- rGoldETF:::plot_gld_chart(
    data_with_indicators,
    type = "line",
    indicators = c("sma", "ema")
  )

  expect_s3_class(p, "ggplot")
})

test_that("plot_gld_chart custom title", {
  custom_title <- "My Custom Chart"
  p <- rGoldETF:::plot_gld_chart(mock_price_history, title = custom_title)

  # Check that title is set
  expect_equal(p$labels$title, custom_title)
})

# ============================================================================
# Visualization Tests - plot_iv_surface()
# Note: plot_iv_surface requires paid subscription and only accepts symbol parameter
# ============================================================================

test_that("plot_iv_surface returns error for free tier", {
  expect_error(
    rGoldETF:::plot_iv_surface("GLD"),
    "paid Twelve Data subscription"
  )
})

# ============================================================================
# Chart Element Tests
# ============================================================================

test_that("Price chart has correct axis labels", {
  p <- rGoldETF:::plot_gld_chart(mock_price_history)

  expect_equal(p$labels$x, "Date")
  expect_equal(p$labels$y, "Price (USD)")
})

# ============================================================================
# Real API Tests - XuanruiQiu
# These tests use real API data for visualization
# Note: Twelve Data free tier allows 8 requests per minute
# ============================================================================

# Helper function to respect API rate limits
.wait_for_api <- function() {
  Sys.sleep(8)  # Wait 8 seconds between API calls to stay under 8/min limit
}

test_that("Real API: plot_gld_chart works with real data", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")

  end_date <- Sys.Date() - 1
  start_date <- end_date - 60

  price_data <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  skip_if(nrow(price_data) < 10, "Not enough data points")

  p <- rGoldETF:::plot_gld_chart(price_data)

  expect_s3_class(p, "ggplot")
  expect_equal(p$labels$x, "Date")
  expect_equal(p$labels$y, "Price (USD)")
})

test_that("Real API: plot_gld_chart line type with real data", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 30

  price_data <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  skip_if(nrow(price_data) < 10, "Not enough data points")

  p <- rGoldETF:::plot_gld_chart(price_data, type = "line")

  expect_s3_class(p, "ggplot")
})

test_that("Real API: plot_gld_chart candlestick type with real data", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 30

  price_data <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  skip_if(nrow(price_data) < 10, "Not enough data points")

  p <- rGoldETF:::plot_gld_chart(price_data, type = "candlestick")

  expect_s3_class(p, "ggplot")
})

test_that("Real API: plot_gld_chart with indicators on real data", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 60

  price_data <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  skip_if(nrow(price_data) < 30, "Not enough data points")

  # Add technical indicators
  data_with_indicators <- get_technical_indicators(
    price_data,
    indicators = c("sma", "ema", "bollinger")
  )

  p <- rGoldETF:::plot_gld_chart(
    data_with_indicators,
    type = "line",
    indicators = c("sma", "ema")
  )

  expect_s3_class(p, "ggplot")
})

test_that("Real API: plot_gld_chart custom title with real data", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 30

  price_data <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  skip_if(nrow(price_data) < 10, "Not enough data points")

  custom_title <- "GLD Price Analysis - Real Data"
  p <- rGoldETF:::plot_gld_chart(price_data, title = custom_title)

  expect_equal(p$labels$title, custom_title)
})

test_that("Real API: Gold spot price functions work", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  result <- rGoldETF:::get_gold_spot_price()

  expect_type(result, "list")
  expect_equal(result$symbol, "XAU/USD")
  expect_true(is.numeric(result$price))
  expect_true(result$price > 1000)  # Gold price should be > $1000/oz
  expect_s3_class(result$timestamp, "POSIXct")
})

test_that("Real API: Gold spot history works", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 30

  result <- rGoldETF:::get_gold_spot_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true(all(c("date", "open", "high", "low", "close") %in% names(result)))
})

test_that("Real API: get_etf_price works for different ETFs", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  # Test with IAU (iShares Gold Trust)
  result <- rGoldETF:::get_etf_price("IAU")

  expect_type(result, "list")
  expect_equal(result$symbol, "IAU")
  expect_true(is.numeric(result$price))
  expect_true(result$price > 0)
})

test_that("Real API: get_etf_history works for different ETFs", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 10

  result <- rGoldETF:::get_etf_history(
    "IAU",
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("Real API: search_gold_symbols returns results", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  result <- rGoldETF:::search_gold_symbols("gold")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true(all(c("symbol", "name", "type", "exchange") %in% names(result)))
})

test_that("Real API: get_market_state returns valid status", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  result <- rGoldETF:::get_market_state("NYSE")

  expect_type(result, "list")
  expect_true("exchange" %in% names(result))
  expect_true("is_open" %in% names(result))
})

# ============================================================================
# Extended Gold Functions Tests (YaojunLiu - Day 4)
# Parameter validation and function existence tests
# ============================================================================

test_that("get_gold_spot_history validates date order", {
  expect_error(
    rGoldETF:::get_gold_spot_history("2024-12-31", "2024-01-01"),
    "start_date must be before end_date"
  )
})

test_that("get_etf_history validates date order", {
  expect_error(
    rGoldETF:::get_etf_history("IAU", "2024-12-31", "2024-01-01"),
    "start_date must be before end_date"
  )
})

test_that("All extended gold functions exist", {
  new_functions <- c(
    "get_gold_spot_price",
    "get_gold_spot_history",
    "get_etf_price",
    "get_etf_history",
    "compare_gold_etfs",
    "search_gold_symbols",
    "get_market_state"
  )

  for (fn in new_functions) {
    expect_true(exists(fn, where = asNamespace("rGoldETF")),
                info = paste("Function", fn, "should exist"))
  }
})

test_that("Real API: compare_gold_etfs returns valid data frame", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  result <- rGoldETF:::compare_gold_etfs(
    symbols = c("GLD"),
    start_date = "2024-01-01",
    end_date = "2024-01-31"
  )

  expect_true(is.data.frame(result))
  expect_true("date" %in% names(result))
  expect_true("symbol" %in% names(result))
  expect_true("normalized" %in% names(result))
})
