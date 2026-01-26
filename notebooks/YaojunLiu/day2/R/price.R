#' Get Historical GLD Data
#'
#' Retrieves historical price data for the GLD ETF from Twelve Data API.
#'
#' @param start_date Start date in "YYYY-MM-DD" format
#' @param end_date End date in "YYYY-MM-DD" format
#' @param interval Data interval: "1day" (daily), "1week" (weekly), "1month" (monthly)
#'
#' @return A data frame containing historical price data
#'
#' @export
get_gld_history <- function(start_date, end_date, interval = "1day") {
  # Validate dates
  start <- as.Date(start_date)
  end <- as.Date(end_date)

  if (start > end) {
    stop("start_date must be before end_date")
  }

  # Map interval to Twelve Data format
  interval_map <- c("1d" = "1day", "1wk" = "1week", "1mo" = "1month")
  if (interval %in% names(interval_map)) {
    interval <- interval_map[interval]
  }

  response <- .api_request("time_series", params = list(
    symbol = "GLD",
    start_date = start_date,
    end_date = end_date,
    interval = interval
  ))

  # Transform Twelve Data response to data frame
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

  # Sort by date ascending
  result <- result[order(result$date), ]
  rownames(result) <- NULL

  result
}
