
# Core Package Stack for Project ------------------------------------------

# Base EpiModel
install.packages("EpiModel")

# Extra Helper Packages
install.packages(c("remotes", "sessioninfo"))

# Latest Versions of EpiModel Packages
remotes::install_github(c("statnet/EpiModel@v1.8.0",
                          "statnet/EpiModelHPC@master",
                          "statnet/tergmLite@v2.1.7",
                          "EpiModel/EpiModelCOVID"),
                        upgrade = FALSE)


# Package Listing ---------------------------------------------------------

library("EpiModelCOVID")
options(width = 100)
sessioninfo::package_info(pkgs = c("network", "networkDynamic", "statnet.common",
                                   "ergm", "tergm", "EpiModel", "EpiModelHPC",
                                   "tergmLite", "EpiModelCOVID"),
                          dependencies = FALSE)

# May 28 2020
# package        * version date       lib source
# EpiModel       * 1.8.0   2020-05-28 [1] Github (statnet/EpiModel@597c403)
# EpiModelCOVID  * 1.0.0   2020-05-28 [1] Github (EpiModel/EpiModelCOVID@b3ab7e5)
# EpiModelHPC      2.1.1   2020-05-18 [1] Github (statnet/EpiModelHPC@a68d3d0)
# ergm           * 3.10.4  2019-06-10 [1] CRAN (R 3.6.1)
# network        * 1.16.0  2019-12-01 [1] CRAN (R 3.6.1)
# networkDynamic * 0.10.1  2020-01-21 [1] CRAN (R 3.6.1)
# statnet.common   4.3.0   2019-06-02 [1] CRAN (R 3.6.1)
# tergm          * 3.6.1   2019-06-12 [1] CRAN (R 3.6.1)
# tergmLite      * 2.1.7   2020-05-18 [1] Github (statnet/tergmLite@b989564)
