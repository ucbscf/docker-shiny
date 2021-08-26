source("/tmp/user-libs.R")

bosf_packages = c(
  "SamplingBigData", "1.0.0",
  "BalancedSampling", "1.5.5"
)

user_libs_install_version("bosf packages", bosf_packages)
