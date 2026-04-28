.onAttach <- function(libname, pkgname) {
  cli::cli_inform(
    cli::cli({
      cli::cli_h1("Welcome to {.pkg {pkgname}}!")
      cli::cli_alert_success("Package loaded successfully!")
      cli::cli_text("Type {.code ?{pkgname}} to see the documentation.")
      cli::cli_text(
        "Visit the package's website for more information: {.url https://eguizarrosales.github.io/YouAnalyser/}"
      )
    }),
    class = "packageStartupMessage"
  )
}
