#!/usr/bin/env Rscript

user_libs_install_version <- function(user_name, user_libs) {
  print(paste("Installing packages for", user_name))
  for (i in seq(1, length(user_libs), 2)) {
    installed_packages <- rownames(installed.packages())
    package_name = user_libs[i]
    version = user_libs[i+1]
    # Only install packages if they haven't already been installed!
    # devtools doesn't do that by default
    if (!package_name %in% installed_packages) {
      print(paste("Installing", package_name, version))
      devtools::install_version(package_name, version, quiet=TRUE)
    } else {
      # FIXME: This ignores version incompatibilities :'(
      print(paste("Not installing", package_name, " as it is already installed"))
    }
  }
  print(paste("Done installing packages for", user_name))
}
