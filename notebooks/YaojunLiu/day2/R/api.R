#' API Configuration and Helper Functions
#'
#' Internal functions for API communication with Twelve Data.
#'
#' @name api
#' @keywords internal
NULL

#' Base URL for the Twelve Data API
#' @noRd
.api_base_url <- function() {
  getOption("rGoldETF.api_url", default = "https://api.twelvedata.com")
}

#' Get API key from environment
#' @noRd
.get_api_key <- function() {
  key <- Sys.getenv("TWELVE_DATA_API_KEY")
  if (key == "") {
    stop("API key not found. Set TWELVE_DATA_API_KEY environment variable.")
  }
  key
}

#' Make API request to Twelve Data
#'
#' @param endpoint API endpoint
#' @param params Query parameters
#' @return Parsed JSON response
#' @noRd
.api_request <- function(endpoint, params = list()) {
  url <- paste0(.api_base_url(), "/", endpoint)

  # Twelve Data uses apikey as query parameter
  params$apikey <- .get_api_key()

  response <- httr::GET(
    url,
    query = params,
    httr::add_headers(
      "Content-Type" = "application/json"
    )
  )

  if (httr::http_error(response)) {
    stop("API request failed: ", httr::status_code(response))
  }

  result <- jsonlite::fromJSON(httr::content(response, "text", encoding = "UTF-8"))

  # Check for Twelve Data API errors
  if (!is.null(result$status) && result$status == "error") {
    stop("Twelve Data API error: ", result$message)
  }

  result
}
