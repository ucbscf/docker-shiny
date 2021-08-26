# koenvdberge; 2021-06-14

source("/tmp/user-libs.R")

packages_3dOES = c(
  "wesanderson", "0.3.6",
  "Formula", "1.2-4",
  "htmlTable", "2.2.1",
  "Hmisc", "4.5-0"
)

user_libs_install_version("3dOES packages", packages_3dOES)

# also used rgl
BiocManager::install("slingshot")
remotes::install_github("daqana/dqshiny")
