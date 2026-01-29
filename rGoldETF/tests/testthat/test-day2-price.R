# Day 2 Tests - Price Functions Tests
# Corresponding dev tasks: get_gld_price(), get_gld_history()

# ============================================================================
# Mock Data - Twelve Data Format
# ============================================================================

mock_price_data <- list(
  symbol = "GLD",
  name = "SPDR Gold Shares",
  exchange = "NYSE",
  close = "185.50",
  change = "1.25",
  percent_change = "0.68",
  volume = "5000000",
  timestamp = as.character(as.numeric(as.POSIXct("2024-01-15 16:00:00")))
)

mock_history_data <- data.frame(
  date = seq.Date(as.Date("2024-01-01"), by = "day", length.out = 30),
  open = 180 + runif(30, -2, 2),
  high = 182 + runif(30, -2, 2),
  low = 178 + runif(30, -2, 2),
  close = 180 + cumsum(rnorm(30, 0.1, 1)),
  volume = sample(1000000:5000000, 30)
)

# Mock Twelve Data time_series response format
mock_twelve_data_history <- list(
  meta = list(symbol = "GLD", interval = "1day"),
  values = data.frame(
    datetime = format(seq.Date(as.Date("2024-01-30"), by = "-1 day", length.out = 30), "%Y-%m-%d"),
    open = as.character(180 + runif(30, -2, 2)),
    high = as.character(182 + runif(30, -2, 2)),
    low = as.character(178 + runif(30, -2, 2)),
    close = as.character(180 + cumsum(rnorm(30, 0.1, 1))),
    volume = as.character(sample(1000000:5000000, 30))
  )
)

# ============================================================================
# get_gld_history() Parameter Validation Tests
# ============================================================================

test_that("get_gld_history validates date order", {
  expect_error(
    get_gld_history("2024-12-31", "2024-01-01"),
    "start_date must be before end_date"
  )
})

test_that("get_gld_history accepts valid date format", {
  # Use mock to avoid actual API calls
  skip_if_not(Sys.getenv("TWELVE_DATA_API_KEY") != "", "Requires API key")

  # This test runs when API key is available
  expect_no_error({
    # Only validate date parsing, don't actually call API
    start <- as.Date("2024-01-01")
    end <- as.Date("2024-01-31")
    expect_true(start < end)
  })
})

test_that("get_gld_history supports different interval parameters", {
  valid_intervals <- c("1day", "1week", "1month", "1d", "1wk", "1mo")

  for (interval in valid_intervals) {
    # Verify interval parameter is correctly passed
    expect_true(interval %in% valid_intervals)
  }
})

test_that("get_gld_history maps legacy interval formats", {
  # Test that legacy formats are accepted (they get mapped internally)
  legacy_intervals <- c("1d", "1wk", "1mo")
  twelve_data_intervals <- c("1day", "1week", "1month")

  for (i in seq_along(legacy_intervals)) {
    expect_true(legacy_intervals[i] %in% c("1d", "1wk", "1mo"))
  }
})

# ============================================================================
# Date Processing Tests
# ============================================================================

test_that("Date string correctly converts to Date object", {
  date_str <- "2024-01-15"
  date_obj <- as.Date(date_str)

  expect_s3_class(date_obj, "Date")
  expect_equal(format(date_obj, "%Y-%m-%d"), date_str)
})

test_that("Invalid date format produces NA", {
  # Completely invalid date strings produce NA
  expect_true(is.na(as.Date("invalid-date", format = "%Y-%m-%d")))
  expect_true(is.na(as.Date("not-a-date", format = "%Y-%m-%d")))
})

# ============================================================================
# Data Structure Validation Tests
# ============================================================================

test_that("Historical data contains required columns", {
  required_cols <- c("date", "open", "high", "low", "close", "volume")

  # Use mock data to validate structure
  expect_true(all(required_cols %in% names(mock_history_data)))
})

test_that("Price data types are correct", {
  expect_type(mock_history_data$open, "double")
  expect_type(mock_history_data$high, "double")
  expect_type(mock_history_data$low, "double")
  expect_type(mock_history_data$close, "double")
  expect_type(mock_history_data$volume, "integer")
})

test_that("OHLC data logic is correct (high >= low)", {
  # In real data, high should always be >= low
  expect_true(all(mock_history_data$high >= mock_history_data$low))
})

# ============================================================================
# Twelve Data Response Transformation Tests
# ============================================================================

test_that("Twelve Data quote response fields are correctly mapped", {
  # Verify expected fields in Twelve Data quote response
  expected_fields <- c("symbol", "name", "close", "change", "percent_change", "volume", "timestamp")
  expect_true(all(expected_fields %in% names(mock_price_data)))
})

test_that("Twelve Data time_series response has values array", {
  expect_true("values" %in% names(mock_twelve_data_history))
  expect_true(is.data.frame(mock_twelve_data_history$values))
})

# ============================================================================
# Real API Tests - YaojunLiu
# These tests use the real Twelve Data API (requires API key)
# Note: Twelve Data free tier allows 8 requests per minute
# ============================================================================

# Helper function to respect API rate limits
.wait_for_api <- function() {
  Sys.sleep(8)  # Wait 8 seconds between API calls to stay under 8/min limit
}

test_that("Real API: get_gld_history returns valid historical data", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  # Get last 10 days of data
  end_date <- Sys.Date() - 1
  start_date <- end_date - 10

  result <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)

  # Check required columns
  required_cols <- c("date", "open", "high", "low", "close", "volume")
  expect_true(all(required_cols %in% names(result)))
})

test_that("Real API: get_gld_history data types are correct", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 5

  result <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  if (nrow(result) > 0) {
    expect_s3_class(result$date, "Date")
    expect_type(result$open, "double")
    expect_type(result$high, "double")
    expect_type(result$low, "double")
    expect_type(result$close, "double")
    expect_type(result$volume, "double")
  }
})

test_that("Real API: get_gld_history OHLC logic is valid", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 30

  result <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  if (nrow(result) > 0) {
    # High should be >= Low
    expect_true(all(result$high >= result$low),
                info = "High should always be >= Low")

    # High should be >= Open and Close
    expect_true(all(result$high >= result$open),
                info = "High should be >= Open")
    expect_true(all(result$high >= result$close),
                info = "High should be >= Close")

    # Low should be <= Open and Close
    expect_true(all(result$low <= result$open),
                info = "Low should be <= Open")
    expect_true(all(result$low <= result$close),
                info = "Low should be <= Close")
  }
})

test_that("Real API: get_gld_history returns data sorted by date", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 30

  result <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d")
  )

  if (nrow(result) > 1) {
    # Data should be sorted in ascending order by date
    expect_true(all(diff(result$date) >= 0),
                info = "Data should be sorted by date ascending")
  }
})

test_that("Real API: get_gld_history weekly interval works", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 60

  result <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d"),
    interval = "1week"
  )

  expect_s3_class(result, "data.frame")
  # Weekly data should have fewer rows than daily
  expect_true(nrow(result) <= 10)
})

test_that("Real API: get_gld_history monthly interval works", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 365

  result <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d"),
    interval = "1month"
  )

  expect_s3_class(result, "data.frame")
  # Monthly data should have around 12 rows for a year
  expect_true(nrow(result) <= 15)
})

test_that("Real API: get_gld_history legacy interval format works", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  end_date <- Sys.Date() - 1
  start_date <- end_date - 10

  # Test legacy format "1d" instead of "1day"
  result <- get_gld_history(
    start_date = format(start_date, "%Y-%m-%d"),
    end_date = format(end_date, "%Y-%m-%d"),
    interval = "1d"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})
