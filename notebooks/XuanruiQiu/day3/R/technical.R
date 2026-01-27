#' Get Technical Indicators
#'
#' Calculates technical indicators for GLD price data.
#'
#' @param data A data frame with historical price data (from get_gld_history)
#' @param indicators Character vector of indicators to calculate.
#'   Options: "sma", "ema" (more coming soon)
#' @param periods Named list of periods for each indicator
#'
#' @return A data frame with the original data plus calculated indicators
#'
#' @export
get_technical_indicators <- function(data,
                                     indicators = c("sma", "ema"),
                                     periods = list(sma = 20, ema = 12)) {
  result <- data

  if ("sma" %in% indicators) {
    result$sma <- .calculate_sma(data$close, periods$sma)
  }

  if ("ema" %in% indicators) {
    result$ema <- .calculate_ema(data$close, periods$ema)
  }

  # RSI, MACD, Bollinger will be added by YaojunLiu

  result
}

#' Calculate Simple Moving Average
#' @noRd
.calculate_sma <- function(x, n) {
  stats::filter(x, rep(1/n, n), sides = 1)
}

#' Calculate Exponential Moving Average
#' @noRd
.calculate_ema <- function(x, n) {
  alpha <- 2 / (n + 1)
  ema <- numeric(length(x))
  ema[1] <- x[1]
  for (i in 2:length(x)) {
    ema[i] <- alpha * x[i] + (1 - alpha) * ema[i-1]
  }
  ema
}
