
# Testing
dat <- init_covid(est, param, init, control, s = 1)
for (at in 2:60) {
  dat <- aging_covid(dat, at)
  dat <- dfunc_covid(dat, at)
  dat <- resim_nets_covid(dat, at)
  dat <- infect_covid(dat, at)
  dat <- progress_covid(dat, at)
  dat <- prevalence_covid(dat, at)
  cat("*")
}

at <- 2

dat <- aging_covid(dat, at)
dat <- dfunc_covid(dat, at)
dat <- resim_nets_covid(dat, at)
dat <- infect_covid(dat, at)
dat <- progress_covid(dat, at)
dat <- prevalence_covid(dat, at)
at <- at + 1
