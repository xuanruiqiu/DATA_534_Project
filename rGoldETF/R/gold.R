#' Get Gold Spot Price (XAU/USD)
#'
#' Retrieves the current gold spot price in USD.
#'
#' @return A list containing gold spot price information
#' @export
get_gold_spot_price <- function() {
  response <- .api_request("exchange_rate", params = list(
    symbol = "XAU/USD"
  ))

  list(
    symbol = "XAU/USD",
    price = as.numeric(response$rate),
    timestamp = as.POSIXct(as.numeric(response$timestamp), origin = "1970-01-01")
  )
}

#' Get Gold Spot Price History
#'
#' Retrieves historical gold spot prices (XAU/USD).
#'
#' @param start_date Start date
#' @param end_date End date
#' @param interval Data interval
#' @return A data frame with historical gold prices
#' @export
get_gold_spot_history <- function(start_date, end_date, interval = "1day") {
  start <- as.Date(start_date)
  end <- as.Date(end_date)

  if (start > end) {
    stop("start_date must be before end_date")
  }

  interval_map <- c("1d" = "1day", "1wk" = "1week", "1mo" = "1month")
  if (interval %in% names(interval_map)) {
    interval <- interval_map[interval]
  }

  response <- .api_request("time_series", params = list(
    symbol = "XAU/USD",
    start_date = start_date,
    end_date = end_date,
    interval = interval
  ))

  if (is.null(response$values) || length(response$values) == 0) {
    return(data.frame(date = as.Date(character()), close = numeric()))
  }

  data <- response$values
  result <- data.frame(
    date = as.Date(data$datetime),
    open = as.numeric(data$open),
    high = as.numeric(data$high),
    low = as.numeric(data$low),
    close = as.numeric(data$close),
    stringsAsFactors = FALSE
  )

  result <- result[order(result$date), ]
  rownames(result) <- NULL
  result
}

#' Get Any ETF Price
#'
#' @param symbol ETF ticker symbol
#' @return A list with price information
#' @export
get_etf_price <- function(symbol) {
  response <- .api_request("quote", params = list(symbol = symbol))

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

#' Get Any ETF History
#'
#' @param symbol ETF ticker symbol
#' @param start_date Start date
#' @param end_date End date
#' @param interval Data interval
#' @return A data frame with historical data
#' @export
get_etf_history <- function(symbol, start_date, end_date, interval = "1day") {
  start <- as.Date(start_date)
  end <- as.Date(end_date)

  if (start > end) {
    stop("start_date must be before end_date")
  }

  interval_map <- c("1d" = "1day", "1wk" = "1week", "1mo" = "1month")
  if (interval %in% names(interval_map)) {
    interval <- interval_map[interval]
  }

  response <- .api_request("time_series", params = list(
    symbol = symbol,
    start_date = start_date,
    end_date = end_date,
    interval = interval
  ))

  if (is.null(response$values) || length(response$values) == 0) {
    return(data.frame(
      date = as.Date(character()),
      open = numeric(),
      high = numeric(),
      low = numeric(),
      close = numeric(),
      volume = numeric()
    ))
  }

  data <- response$values
  result <- data.frame(
    date = as.Date(data$datetime),
    open = as.numeric(data$open),
    high = as.numeric(data$high),
    low = as.numeric(data$low),
    close = as.numeric(data$close),
    volume = as.numeric(data$volume),
    stringsAsFactors = FALSE
  )

  result <- result[order(result$date), ]
  rownames(result) <- NULL
  result
}

#' Compare Multiple Gold ETFs
#'
#' @param symbols Vector of ETF symbols
#' @param start_date Start date
#' @param end_date End date
#' @return Data frame with normalized prices for comparison
#' @export
compare_gold_etfs <- function(symbols = c("GLD", "IAU", "SGOL"),
                               start_date, end_date) {
  result <- NULL

  for (sym in symbols) {
    tryCatch({
      data <- get_etf_history(sym, start_date, end_date)
      if (nrow(data) > 0) {
        # Normalize to 100 at start
        data$normalized <- (data$close / data$close[1]) * 100
        data$symbol <- sym
        data <- data[, c("date", "symbol", "close", "normalized")]

        if (is.null(result)) {
          result <- data
        } else {
          result <- rbind(result, data)
        }
      }
    }, error = function(e) {
      warning(paste("Failed to fetch data for", sym))
    })
  }

  result
}

#' Search for Gold-Related Symbols
#'
#' @param query Search query
#' @return Data frame with matching symbols
#' @export
search_gold_symbols <- function(query = "gold") {
  response <- .api_request("symbol_search", params = list(symbol = query))

  if (is.null(response$data)) {
    return(data.frame(symbol = character(), name = character()))
  }

  data.frame(
    symbol = response$data$symbol,
    name = response$data$instrument_name,
    type = response$data$instrument_type,
    exchange = response$data$exchange,
    stringsAsFactors = FALSE
  )
}

#' Get Market State
#'
#' @param exchange Exchange code (default: "NYSE")
#' @return List with market state information
#' @export
get_market_state <- function(exchange = "NYSE") {
  response <- .api_request("market_state", params = list(exchange = exchange))

  if (is.data.frame(response) && nrow(response) > 0) {
    row <- response[1, ]
    list(
      exchange = row$name,
      code = row$code,
      is_open = row$is_market_open,
      time_to_open = row$time_to_open,
      time_to_close = row$time_to_close
    )
  } else {
    list(exchange = exchange, is_open = NA)
  }
}
