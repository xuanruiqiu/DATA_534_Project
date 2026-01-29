# Global variables for ggplot2 NSE
utils::globalVariables(c("date", "close", "low", "high", "open", "direction",
                         "sma", "ema", "bb_upper", "bb_lower", "normalized", "symbol",
                         "value", "indicator"))

#' Plot GLD Price Chart
#'
#' Creates a price chart for GLD ETF data.
#'
#' @param data A data frame with price data (from get_gld_history)
#' @param type Chart type: "line" or "candlestick"
#' @param indicators Character vector of indicators to overlay (requires pre-calculated)
#' @param title Chart title
#'
#' @return A ggplot object
#'
#' @export
#' @import ggplot2
plot_gld_chart <- function(data,
                           type = "line",
                           indicators = NULL,
                           title = "GLD Price Chart") {

  # Add direction column for candlestick BEFORE creating ggplot
  if (type == "candlestick") {
    data$direction <- ifelse(data$close >= data$open, "up", "down")
  }

  # Base plot
  p <- ggplot(data, aes(x = date))

  # Define color mapping for legend
  line_colors <- c("Price" = "steelblue", "SMA" = "orange", "EMA" = "purple",
                   "Bollinger Bands" = "gray")

  # Track if we need color scale
  has_color_aes <- FALSE

  if (type == "line") {
    p <- p + geom_line(aes(y = close, color = "Price"), linewidth = 0.8)
    has_color_aes <- TRUE
  } else if (type == "candlestick") {
    p <- p +
      geom_segment(aes(x = date, xend = date, y = low, yend = high)) +
      geom_rect(aes(
        xmin = date - 0.3,
        xmax = date + 0.3,
        ymin = pmin(open, close),
        ymax = pmax(open, close),
        fill = direction
      )) +
      scale_fill_manual(values = c("up" = "green", "down" = "red"), guide = "none")
  }

  # Add indicators if specified
  if (!is.null(indicators)) {
    if ("sma" %in% indicators && "sma" %in% names(data)) {
      p <- p + geom_line(aes(y = sma, color = "SMA"), linewidth = 0.6, na.rm = TRUE)
      has_color_aes <- TRUE
    }
    if ("ema" %in% indicators && "ema" %in% names(data)) {
      p <- p + geom_line(aes(y = ema, color = "EMA"), linewidth = 0.6, na.rm = TRUE)
      has_color_aes <- TRUE
    }
    if ("bb_upper" %in% names(data) && "bollinger" %in% indicators) {
      p <- p +
        geom_line(aes(y = bb_upper, color = "Bollinger Bands"), linetype = "dashed", na.rm = TRUE) +
        geom_line(aes(y = bb_lower, color = "Bollinger Bands"), linetype = "dashed", na.rm = TRUE)
      has_color_aes <- TRUE
    }
  }

  # Add color scale for legend only if color aesthetic is used
  if (has_color_aes) {
    p <- p + scale_color_manual(values = line_colors)
  }

  # Styling
  p <- p +
    labs(
      title = title,
      x = "Date",
      y = "Price (USD)",
      color = NULL
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.text.x = element_text(angle = 45, hjust = 1),
      legend.position = "bottom"
    )

  p
}

#' Plot Gold vs Bitcoin Price Comparison
#'
#' Creates a normalized price comparison chart for Gold (XAU/USD) and Bitcoin (BTC/USD).
#' Prices are normalized to start at 100 for easy comparison.
#'
#' @param start_date Start date in "YYYY-MM-DD" format or Date object
#' @param end_date End date in "YYYY-MM-DD" format or Date object
#' @param interval Data interval: "1day", "1week", or "1month"
#'
#' @return A ggplot object
#'
#' @export
#' @import ggplot2
#' @examples
#' \dontrun{
#' # Compare Gold vs Bitcoin for the last 30 days
#' plot_asset_comparison(start_date = Sys.Date() - 30, end_date = Sys.Date())
#'
#' # Weekly comparison
#' plot_asset_comparison(start_date = "2024-01-01", end_date = "2024-06-30", interval = "1week")
#' }
plot_asset_comparison <- function(start_date,
                                  end_date,
                                  interval = "1day") {
  # Fixed symbols: Gold and Bitcoin

  symbol1 <- "XAU/USD"
  symbol2 <- "BTC/USD"

  # Validate dates
  start_date <- as.character(as.Date(start_date))
  end_date <- as.character(as.Date(end_date))

  # Fetch data for both assets
  data1 <- .api_request("time_series", params = list(
    symbol = symbol1,
    start_date = start_date,
    end_date = end_date,
    interval = interval
  ))

  data2 <- .api_request("time_series", params = list(
    symbol = symbol2,
    start_date = start_date,
    end_date = end_date,
    interval = interval
  ))

  # Helper function to process API response
  process_data <- function(response, symbol) {
    if (is.null(response$values) || length(response$values) == 0) {
      return(NULL)
    }
    data <- response$values
    df <- data.frame(
      date = as.Date(data$datetime),
      close = as.numeric(data$close),
      symbol = symbol,
      stringsAsFactors = FALSE
    )
    df <- df[order(df$date), ]
    # Normalize: starting value = 100
    df$normalized <- (df$close / df$close[1]) * 100
    df
  }

  df1 <- process_data(data1, symbol1)
  df2 <- process_data(data2, symbol2)

  if (is.null(df1) || is.null(df2)) {
    stop("Failed to retrieve data for Gold or Bitcoin.")
  }

  # Combine data
  combined <- rbind(df1, df2)

  # Create plot
  p <- ggplot(combined, aes(x = date, y = normalized, color = symbol)) +
    geom_line(linewidth = 0.8) +
    scale_color_manual(
      values = c("XAU/USD" = "gold3", "BTC/USD" = "orange"),
      labels = c("XAU/USD" = "Gold", "BTC/USD" = "Bitcoin")
    ) +
    labs(
      title = "Gold vs Bitcoin - Normalized Price Comparison",
      x = "Date",
      y = "Normalized Price (Start = 100)",
      color = "Asset"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.text.x = element_text(angle = 45, hjust = 1),
      legend.position = "bottom"
    )

  p
}
