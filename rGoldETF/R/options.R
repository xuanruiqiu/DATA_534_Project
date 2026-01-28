#' Options Functions (Requires Paid Subscription)
#'
#' Note: Options data from Twelve Data API requires a paid subscription.
#' These functions are placeholders and will return an error message.
#'
#' @name options
#' @keywords internal
NULL

#' Get Options Chain
#'
#' Note: This function requires a paid Twelve Data subscription.
#'
#' @param symbol Ticker symbol (default: "GLD")
#' @param expiration Expiration date
#' @param option_type Type of options
#'
#' @return Error message indicating paid subscription required
#'
#' @export
get_options_chain <- function(symbol = "GLD",
                              expiration = NULL,
                              option_type = "both") {

  stop("Options data requires a paid Twelve Data subscription. ",
       "Visit https://twelvedata.com/pricing for more information.")
}

#' Get Implied Volatility
#'
#' Note: This function requires a paid Twelve Data subscription.
#'
#' @param symbol Ticker symbol (default: "GLD")
#' @param expiration Expiration date
#'
#' @return Error message indicating paid subscription required
#'
#' @export
get_implied_volatility <- function(symbol = "GLD", expiration = NULL) {
  stop("Options data requires a paid Twelve Data subscription. ",
       "Visit https://twelvedata.com/pricing for more information.")
}

#' Plot Implied Volatility Surface
#'
#' Note: This function requires a paid Twelve Data subscription.
#'
#' @param symbol Ticker symbol (default: "GLD")
#'
#' @return Error message indicating paid subscription required
#'
#' @export
plot_iv_surface <- function(symbol = "GLD") {
  stop("Options data requires a paid Twelve Data subscription. ",
       "Visit https://twelvedata.com/pricing for more information.")
}
