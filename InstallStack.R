
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

# June 10 2020
# package        * version   date       lib source
# EpiModel       * 1.8.0     2020-06-10 [1] Github (statnet/EpiModel@597c403)
# EpiModelCOVID  * 1.0.0     2020-06-10 [1] Github (EpiModel/EpiModelCOVID@7835110)
# EpiModelHPC      2.1.1     2020-06-10 [1] Github (statnet/EpiModelHPC@a68d3d0)
# ergm           * 3.10.4    2019-06-10 [1] CRAN (R 3.6.0)
# network        * 1.16.0    2019-12-01 [1] CRAN (R 3.6.0)
# networkDynamic * 0.10.1    2020-01-21 [1] CRAN (R 3.6.0)
# statnet.common   4.3.0-230 2020-01-14 [1] Github (statnet/statnet.common@3307a8c)
# tergm          * 3.6.1     2019-06-12 [1] CRAN (R 3.6.0)
# tergmLite      * 2.1.7     2020-05-17 [1] Github (statnet/tergmLite@b989564)

