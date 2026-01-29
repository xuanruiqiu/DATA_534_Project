# Day 1 Tests - API Foundation Tests and Test Framework Setup
# Corresponding dev tasks: Package skeleton + DESCRIPTION, api.R core functions, Test framework setup

# ============================================================================
# Test Helper Functions and Mock Data
# ============================================================================

#' Create Mock API Response
mock_api_response <- function(data, status_code = 200) {
  structure(
    list(
      content = charToRaw(jsonlite::toJSON(data)),
      status_code = status_code
    ),
    class = "response"
  )
}

#' Create Mock Twelve Data Quote Response
mock_twelve_data_quote <- function() {
  list(
    symbol = "GLD",
    name = "SPDR Gold Shares",
    exchange = "NYSE",
    close = "185.50",
    change = "1.25",
    percent_change = "0.68",
    volume = "5000000",
    timestamp = as.character(as.numeric(Sys.time()))
  )
}

#' Create Mock Twelve Data Time Series Response
mock_twelve_data_time_series <- function() {
  list(
    meta = list(symbol = "GLD", interval = "1day"),
    values = data.frame(
      datetime = c("2024-01-15", "2024-01-14", "2024-01-13"),
      open = c("180.50", "179.25", "178.00"),
      high = c("182.00", "181.50", "180.25"),
      low = c("179.75", "178.50", "177.50"),
      close = c("181.25", "180.50", "179.25"),
      volume = c("5000000", "4500000", "4800000")
    )
  )
}

# ============================================================================
# API Configuration Tests
# ============================================================================

test_that("API base URL can be configured via options", {
  # Save original setting
  old_url <- getOption("rGoldETF.api_url")

  # Set new URL
  options(rGoldETF.api_url = "https://custom.api.com")
  expect_equal(getOption("rGoldETF.api_url"), "https://custom.api.com")

  # Restore original setting
  options(rGoldETF.api_url = old_url)
})

test_that("Default API URL is Twelve Data", {
  # Save original setting
  old_url <- getOption("rGoldETF.api_url")

  # Clear option to test default
  options(rGoldETF.api_url = NULL)

  # Check default URL
  expect_equal(rGoldETF:::.api_base_url(), "https://api.twelvedata.com")

  # Restore original setting
  options(rGoldETF.api_url = old_url)
})

test_that("Missing API key throws error", {
  # Save original key
  old_key <- Sys.getenv("TWELVE_DATA_API_KEY")

  # Clear API key
  Sys.setenv(TWELVE_DATA_API_KEY = "")

  expect_error(
    rGoldETF:::.get_api_key(),
    "API key not found"
  )

  # Restore original key
  Sys.setenv(TWELVE_DATA_API_KEY = old_key)
})

test_that("API key is returned correctly when present", {
  # Save original key
  old_key <- Sys.getenv("TWELVE_DATA_API_KEY")

  # Set test key
  Sys.setenv(TWELVE_DATA_API_KEY = "test_api_key_12345")

  expect_equal(rGoldETF:::.get_api_key(), "test_api_key_12345")

  # Restore original key
  Sys.setenv(TWELVE_DATA_API_KEY = old_key)
})

# ============================================================================
# Package Load Tests
# ============================================================================

test_that("Package sets default options on load", {
  # Check that default API URL is set
  expect_true(!is.null(getOption("rGoldETF.api_url")))
})

# ============================================================================
# Real API Tests - XuanruiQiu
# These tests use the real Twelve Data API (requires API key)
# Note: Twelve Data free tier allows 8 requests per minute
# ============================================================================

# Helper function to respect API rate limits
.wait_for_api <- function() {
  Sys.sleep(8)  # Wait 8 seconds between API calls to stay under 8/min limit
}

test_that("Real API: .api_request successfully connects to Twelve Data", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")

  # Test basic API connectivity with a simple quote request
  result <- rGoldETF:::.api_request("quote", params = list(symbol = "GLD"))

  expect_type(result, "list")
  expect_true("symbol" %in% names(result))
  expect_equal(result$symbol, "GLD")
})

test_that("Real API: API returns valid response structure for quote endpoint", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  result <- rGoldETF:::.api_request("quote", params = list(symbol = "GLD"))

  # Verify expected fields from Twelve Data quote response
  expected_fields <- c("symbol", "name", "exchange", "close", "volume", "timestamp")
  for (field in expected_fields) {
    expect_true(field %in% names(result),
                info = paste("Expected field", field, "in response"))
  }
})

test_that("Real API: API handles invalid symbol gracefully", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  # Invalid symbol should return an error from Twelve Data

  expect_error(
    rGoldETF:::.api_request("quote", params = list(symbol = "INVALID_SYMBOL_XYZ123")),
    "Twelve Data API error"
  )
})

test_that("Real API: time_series endpoint returns valid data", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  result <- rGoldETF:::.api_request("time_series", params = list(
    symbol = "GLD",
    interval = "1day",
    outputsize = 5
  ))

  expect_type(result, "list")
  expect_true("values" %in% names(result) || "meta" %in% names(result))
})

test_that("Real API: exchange_rate endpoint works for XAU/USD", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  result <- rGoldETF:::.api_request("exchange_rate", params = list(
    symbol = "XAU/USD"
  ))

  expect_type(result, "list")
  expect_true("rate" %in% names(result))
  expect_true(as.numeric(result$rate) > 0)
})

test_that("Real API: symbol_search endpoint returns results", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  result <- rGoldETF:::.api_request("symbol_search", params = list(
    symbol = "gold"
  ))

  expect_type(result, "list")
  expect_true("data" %in% names(result))
  expect_true(length(result$data) > 0)
})

test_that("Real API: market_state endpoint returns exchange status", {
  skip_if(Sys.getenv("TWELVE_DATA_API_KEY") == "", "Requires TWELVE_DATA_API_KEY")
  .wait_for_api()

  result <- rGoldETF:::.api_request("market_state", params = list(
    exchange = "NYSE"
  ))

  expect_true(is.data.frame(result) || is.list(result))
})
