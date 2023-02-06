#!/usr/bin/env Rscript

source("/tmp/user-libs.R")

packages_paciorek = c(
  "shinydashboard", "0.7.2"
)

user_libs_install_version("paciorek packages", packages_paciorek)
