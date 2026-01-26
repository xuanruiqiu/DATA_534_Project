#' Get Current GLD Price
#'
#' Retrieves the current price of the GLD ETF from Twelve Data API.
#'
#' @return A list containing current price information including:
#'   \item{symbol}{The ticker symbol (GLD)}
#'   \item{name}{ETF name}
#'   \item{price}{Current price}
#'   \item{change}{Price change}
#'   \item{change_percent}{Percentage change}
#'   \item{volume}{Trading volume}
#'   \item{timestamp}{Time of the quote}
#'
#' @export
#' @examples
#' \dontrun{
#' price <- get_gld_price()
#' print(price$price)
#' }
get_gld_price <- function() {
  response <- .api_request("quote", params = list(symbol = "GLD"))

  # Transform Twelve Data response to standardized format
  list(
    symbol = response$symbol,
    name = response$name,
    price = as.numeric(response$close),
    change = as.numeric(response$change),
    change_percent = as.numeric(response$percent_change),
    volume = as.numeric(response$volume),
    timestamp = as.POSIXct(as.numeric(response$timestamp), origin = "1970-01-01")
  )
}
