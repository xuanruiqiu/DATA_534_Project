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

  # Base plot
  p <- ggplot(data, aes(x = date))

  if (type == "line") {
    p <- p + geom_line(aes(y = close), color = "steelblue", linewidth = 0.8)
  } else if (type == "candlestick") {
    # Candlestick chart
    data$direction <- ifelse(data$close >= data$open, "up", "down")

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
      p <- p + geom_line(aes(y = sma), color = "orange", linewidth = 0.6, na.rm = TRUE)
    }
    if ("ema" %in% indicators && "ema" %in% names(data)) {
      p <- p + geom_line(aes(y = ema), color = "purple", linewidth = 0.6, na.rm = TRUE)
    }
    if ("bb_upper" %in% names(data) && "bollinger" %in% indicators) {
      p <- p +
        geom_line(aes(y = bb_upper), color = "gray", linetype = "dashed", na.rm = TRUE) +
        geom_line(aes(y = bb_lower), color = "gray", linetype = "dashed", na.rm = TRUE)
    }
  }

  # Styling
  p <- p +
    labs(
      title = title,
      x = "Date",
      y = "Price (USD)"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.text.x = element_text(angle = 45, hjust = 1)
    )

  p
}
