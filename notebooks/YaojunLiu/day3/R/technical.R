#' Get Technical Indicators
#'
#' Calculates technical indicators for GLD price data.
#'
#' @param data A data frame with historical price data (from get_gld_history)
#' @param indicators Character vector of indicators to calculate.
#'   Options: "sma", "ema", "rsi", "macd", "bollinger"
#' @param periods Named list of periods for each indicator
#'
#' @return A data frame with the original data plus calculated indicators
#'
#' @export
get_technical_indicators <- function(data,
                                     indicators = c("sma", "ema", "rsi"),
                                     periods = list(sma = 20, ema = 12, rsi = 14)) {
  result <- data

  if ("sma" %in% indicators) {
    result$sma <- .calculate_sma(data$close, periods$sma)
  }

  if ("ema" %in% indicators) {
    result$ema <- .calculate_ema(data$close, periods$ema)
  }

  # YaojunLiu's additions
  if ("rsi" %in% indicators) {
    result$rsi <- .calculate_rsi(data$close, periods$rsi)
  }

  if ("macd" %in% indicators) {
    macd_result <- .calculate_macd(data$close)
    result$macd <- macd_result$macd
    result$macd_signal <- macd_result$signal
    result$macd_histogram <- macd_result$histogram
  }

  if ("bollinger" %in% indicators) {
    bb_result <- .calculate_bollinger(data$close, periods$sma)
    result$bb_upper <- bb_result$upper
    result$bb_middle <- bb_result$middle
    result$bb_lower <- bb_result$lower
  }

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

#' Calculate RSI
#' @noRd
.calculate_rsi <- function(x, n = 14) {
  delta <- diff(x)
  gains <- pmax(delta, 0)
  losses <- pmax(-delta, 0)

  avg_gain <- .calculate_sma(gains, n)
  avg_loss <- .calculate_sma(losses, n)

  rs <- avg_gain / avg_loss
  rsi <- 100 - (100 / (1 + rs))
  c(NA, rsi)  # Add NA for first value (no diff)
}

#' Calculate MACD
#' @noRd
.calculate_macd <- function(x, fast = 12, slow = 26, signal = 9) {
  ema_fast <- .calculate_ema(x, fast)
  ema_slow <- .calculate_ema(x, slow)
  macd <- ema_fast - ema_slow
  signal_line <- .calculate_ema(macd, signal)
  histogram <- macd - signal_line

  list(macd = macd, signal = signal_line, histogram = histogram)
}

#' Calculate Bollinger Bands
#' @noRd
.calculate_bollinger <- function(x, n = 20, sd_mult = 2) {
  middle <- .calculate_sma(x, n)
  sd <- stats::sd(x, na.rm = TRUE)
  upper <- middle + sd_mult * sd
  lower <- middle - sd_mult * sd

  list(upper = upper, middle = middle, lower = lower)
}
