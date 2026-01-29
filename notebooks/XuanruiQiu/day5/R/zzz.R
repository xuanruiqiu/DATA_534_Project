#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom stats filter sd
## usethis namespace: end
NULL

.onLoad <- function(libname, pkgname) {
  op <- options()
  op.rGoldETF <- list(
    rGoldETF.api_url = "https://api.twelvedata.com"
  )
  toset <- !(names(op.rGoldETF) %in% names(op))
  if (any(toset)) options(op.rGoldETF[toset])

  invisible()
}

.onAttach <- function(libname, pkgname) {
  packageStartupMessage("rGoldETF: Gold ETF Data Analysis and Visualization")
  packageStartupMessage("Powered by Twelve Data API (https://twelvedata.com)")
  packageStartupMessage("Set your API key with: Sys.setenv(TWELVE_DATA_API_KEY = 'your_key')")
  packageStartupMessage("Or use: gld_set_api_key('your_key')")
}
