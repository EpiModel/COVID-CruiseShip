
##
## COVID-19 Cruise Ship Network Model
##
## Authors: Samuel M. Jenness
## Date: February 2020
##

# New Initialization Module -----------------------------------------------

init_covid <- function(x, param, init, control, s) {

  browser()

  # Master Data List
  dat <- list()
  dat$param <- param
  dat$init <- init
  dat$control <- control

  dat$attr <- list()
  dat$stats <- list()
  dat$temp <- list()

  ## Network Setup ##
  # Initial network simulations
  dat$nw <- list()
  for (i in 1:2) {
  }
  nw <- dat$nw

  # Pull Network parameters
  dat$nwparam <- list()
  for (i in 1:2) {
    dat$nwparam[i] <- list(x[[i]][-which(names(x[[i]]) == "fit")])
  }

  # Convert to tergmLite method
  dat <- init_tergmLite(dat)

  ## Nodal Attributes Setup ##
  dat$attr <- param$netstats$attr

  num <- network.size(nw[[1]])
  dat$attr$active <- rep(1, num)
  dat$attr$arrival.time <- rep(1, num)
  dat$attr$uid <- 1:num

  # Initialization

  ## Pull network val to attr
  stop()

  ## Store current proportions of attr
  dat$temp$fterms <- fterms
  dat$temp$t1.tab <- get_attr_prop(dat$nw, fterms)

  ## Infection Status and Time Modules
  dat <- init_status.net(dat)

  ## Get initial prevalence
  dat <- get_prev.net(dat, at = 1)

  return(dat)
}


# New Network Resimulation Module -----------------------------------------

resim_nets_covid <- function(dat, at) {

  ## Edges correction
  dat <- edges_correct_covid(dat, at)

  ## pass/pass network
  nwparam1 <- EpiModel::get_nwparam(dat, network = 1)
  dat <- tergmLite::updateModelTermInputs(dat, network = 1)

  dat$el[[1]] <- tergmLite::simulate_ergm(p = dat$p[[3]],
                                          el = dat$el[[3]],
                                          coef = nwparam1$coef.form)


  ## other network
  nwparam2 <- EpiModel::get_nwparam(dat, network = 2)
  dat <- tergmLite::updateModelTermInputs(dat, network = 2)

  dat$el[[2]] <- tergmLite::simulate_ergm(p = dat$p[[3]],
                                          el = dat$el[[3]],
                                          coef = nwparam2$coef.form)

  if (dat$control$save.nwstats == TRUE) {
    dat <- calc_nwstats_covid(dat, at)
  }

  return(dat)
}

edges_correct_covid <- function(dat, at) {

  old.num <- dat$epi$num[at - 1]
  new.num <- sum(dat$attr$active == 1, na.rm = TRUE)
  adjust <- log(old.num) - log(new.num)

  coef.form1 <- get_nwparam(dat, network = 1)$coef.form
  coef.form1[1] <- coef.form1[1] + adjust
  dat$nwparam[[1]]$coef.form <- coef.form1

  coef.form2 <- get_nwparam(dat, network = 2)$coef.form
  coef.form2[1] <- coef.form2[1] + adjust
  dat$nwparam[[2]]$coef.form <- coef.form2

  return(dat)
}

calc_nwstats_covid <- function(dat, at) {

  for (nw in 1:3) {
    n <- attr(dat$el[[nw]], "n")
    edges <- nrow(dat$el[[nw]])
    meandeg <- round(edges * (2/n), 3)
    concurrent <- round(mean(get_degree(dat$el[[nw]]) > 1), 3)
    mat <- matrix(c(edges, meandeg, concurrent), ncol = 3, nrow = 1)
    if (at == 1) {
      dat$stats$nwstats[[nw]] <- mat
      colnames(dat$stats$nwstats[[nw]]) <- c("edges", "mdeg", "conc")
    }
    if (at > 1) {
      dat$stats$nwstats[[nw]] <- rbind(dat$stats$nwstats[[nw]], mat)
    }
  }

  return(dat)
}

# Replacement infection/transmission module -------------------------------

infect_covid <- function(dat, at) {

  ## Uncomment this to function environment interactively
  # browser()

  ## Attributes ##
  active <- dat$attr$active
  status <- dat$attr$status

  ## Parameters ##
  inf.prob <- dat$param$inf.prob
  act.rate <- dat$param$act.rate

  ## Find infected nodes ##
  idsInf <- which(active == 1 & status == "i")
  nActive <- sum(active == 1)
  nElig <- length(idsInf)

  ## Initialize default incidence at 0 ##
  nInf <- 0

  ## If any infected nodes, proceed with transmission ##
  if (nElig > 0 && nElig < nActive) {

    ## Look up discordant edgelist ##
    del <- discord_edgelist(dat, at)

    ## If any discordant pairs, proceed ##
    if (!(is.null(del))) {

      # Set parameters on discordant edgelist data frame
      del$transProb <- inf.prob
      del$actRate <- act.rate
      del$finalProb <- 1 - (1 - del$transProb)^del$actRate

      # Stochastic transmission process
      transmit <- rbinom(nrow(del), 1, del$finalProb)

      # Keep rows where transmission occurred
      del <- del[which(transmit == 1), ]

      # Look up new ids if any transmissions occurred
      idsNewInf <- unique(del$sus)
      nInf <- length(idsNewInf)

      # Set new attributes for those newly infected
      if (nInf > 0) {
        dat$attr$status[idsNewInf] <- "e"
        dat$attr$infTime[idsNewInf] <- at
      }
    }
  }

  ## Save summary statistic for S->E flow
  dat$epi$se.flow[at] <- nInf

  return(dat)
}


# New disease progression module ------------------------------------------
# (Replaces the recovery module)

progress_covid <- function(dat, at) {

  ## Uncomment this to function environment interactively
  # browser()

  ## Attributes ##
  active <- dat$attr$active
  status <- dat$attr$status

  ## Parameters ##
  ei.rate <- dat$param$ei.rate
  ir.rate <- dat$param$ir.rate

  ## E to I progression process ##
  nInf <- 0
  idsEligInf <- which(active == 1 & status == "e")
  nEligInf <- length(idsEligInf)

  if (nEligInf > 0) {
    vecInf <- which(rbinom(nEligInf, 1, ei.rate) == 1)
    if (length(vecInf) > 0) {
      idsInf <- idsEligInf[vecInf]
      nInf <- length(idsInf)
      status[idsInf] <- "i"
    }
  }

  ## I to R progression process ##
  nRec <- 0
  idsEligRec <- which(active == 1 & status == "i")
  nEligRec <- length(idsEligRec)

  if (nEligRec > 0) {
    vecRec <- which(rbinom(nEligRec, 1, ir.rate) == 1)
    if (length(vecRec) > 0) {
      idsRec <- idsEligRec[vecRec]
      nRec <- length(idsRec)
      status[idsRec] <- "r"
    }
  }

  ## Write out updated status attribute ##
  dat$attr$status <- status

  ## Save summary statistics ##
  dat$epi$ei.flow[at] <- nInf
  dat$epi$ir.flow[at] <- nRec
  dat$epi$e.num[at] <- sum(active == 1 & status == "e")
  dat$epi$r.num[at] <- sum(active == 1 & status == "r")

  return(dat)
}

