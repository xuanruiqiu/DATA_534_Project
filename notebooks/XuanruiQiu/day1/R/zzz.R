#' @keywords internal
"_PACKAGE"

.onLoad <- function(libname, pkgname) {

  # Set default options - placeholder URL for now
  op <- options()
  op.rGoldETF <- list(
    rGoldETF.api_url = "https://api.example.com"
  )
  toset <- !(names(op.rGoldETF) %in% names(op))
  if (any(toset)) options(op.rGoldETF[toset])

  invisible()
}

.onAttach <- function(libname, pkgname) {
  packageStartupMessage("rGoldETF: Gold ETF Data Analysis and Visualization")
  packageStartupMessage("Set your API key with: Sys.setenv(GOLD_ETF_API_KEY = 'your_key')")
}
