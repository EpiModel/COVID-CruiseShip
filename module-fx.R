
##
## COVID-19 Cruise Ship Network Model
##
## Authors: Samuel M. Jenness
## Date: February 2020
##


# Initialization Module ---------------------------------------------------

init_covid <- function(x, param, init, control, s) {

  # Master Data List
  dat <- list()
  dat$param <- param
  dat$init <- init
  dat$control <- control

  dat$attr <- list()
  dat$stats <- list()
  dat$stats$nwstats <- list()
  dat$temp <- list()

  ## Network Setup ##
  # Initial network simulations
  dat$nw <- list()
  for (i in 1:2) {
    dat$nw[[i]] <- simulate(x[[i]]$fit, basis = x[[i]]$fit$newnetwork)
  }
  nw <- dat$nw

  # Pull Network parameters
  dat$nwparam <- list()
  for (i in 1:2) {
    dat$nwparam[i] <- list(x[[i]][-which(names(x[[i]]) == "fit")])
  }

  ## Nodal Attributes Setup ##
  num <- network.size(nw[[1]])
  dat$attr$active <- rep(1, num)
  dat$attr$arrival.time <- rep(1, num)
  dat$attr$uid <- 1:num

  dat$attr$pass.room <- get.vertex.attribute(nw[[1]], "pass.room")
  dat$attr$type <- get.vertex.attribute(nw[[1]], "type")

  # Convert to tergmLite method
  dat <- init_tergmLite(dat)

  ## Infection Status and Time Modules
  dat <- init_status_covid(dat)

  ## Get initial prevalence
  dat <- prevalence_covid(dat, at = 1)

  # Network stats
  if (dat$control$save.nwstats == TRUE) {
    dat <- calc_nwstats_covid(dat, at = 1)
  }

  return(dat)
}

init_status_covid <- function(dat) {

  e.num <- dat$init$e.num

  active <- dat$attr$active
  num <- sum(dat$attr$active)

  ## Disease status
  status <- rep("s", num)
  status[sample(which(active == 1), size = e.num)] <- "e"
  dat$attr$status <- status

  ## Save out other attr
  dat$attr$active <- rep(1, length(status))
  dat$attr$entrTime <- rep(1, length(status))
  dat$attr$exitTime <- rep(NA, length(status))


  # Infection Time
  ## Set up inf.time vector
  idsInf <- which(status == "e")
  infTime <- rep(NA, length(status))
  infTime[idsInf] <- -rgeom(n = length(idsInf), prob = mean(dat$param$ei.rate)) + 2

  dat$attr$infTime <- infTime

  return(dat)
}


# Network Resimulation Module ---------------------------------------------

resim_nets_covid <- function(dat, at) {

  ## Edges correction
  dat <- edges_correct_covid(dat, at)

  ## pass/pass network
  nwparam1 <- EpiModel::get_nwparam(dat, network = 1)
  dat <- tergmLite::updateModelTermInputs(dat, network = 1)

  dat$el[[1]] <- tergmLite::simulate_ergm(p = dat$p[[1]],
                                          el = dat$el[[1]],
                                          coef = nwparam1$coef.form)


  ## other network
  nwparam2 <- EpiModel::get_nwparam(dat, network = 2)
  dat <- tergmLite::updateModelTermInputs(dat, network = 2)

  dat$el[[2]] <- tergmLite::simulate_ergm(p = dat$p[[2]],
                                          el = dat$el[[2]],
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

  for (nw in 1:2) {
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


# Infection Module --------------------------------------------------------

infect_covid <- function(dat, at) {

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
  nInf1 <- nInf2 <- 0

  if (length(idsInf) > 0) {

    ## Look up discordant edgelist ##
    del1 <- discord_edgelist_covid(dat, nw = 1)

    ## If any discordant pairs, proceed ##
    if (!(is.null(del1))) {

      # Set parameters on discordant edgelist data frame
      del1$transProb <- inf.prob
      del1$actRate <- act.rate
      del1$finalProb <- 1 - (1 - del1$transProb)^del1$actRate

      # Stochastic transmission process
      transmit <- rbinom(nrow(del1), 1, del1$finalProb)

      # Keep rows where transmission occurred
      del1 <- del1[which(transmit == 1), ]

      # Look up new ids if any transmissions occurred
      idsNewInf1 <- unique(del1$sus)
      nInf1 <- length(idsNewInf1)

      # Set new attributes for those newly infected
      if (nInf1 > 0) {
        dat$attr$status[idsNewInf1] <- "e"
        dat$attr$infTime[idsNewInf1] <- at
      }
    }

    del2 <- discord_edgelist_covid(dat, nw = 2)
    if (!(is.null(del2))) {

      # Set parameters on discordant edgelist data frame
      del2$transProb <- inf.prob
      del2$actRate <- act.rate
      del2$finalProb <- 1 - (1 - del2$transProb)^del2$actRate

      # Stochastic transmission process
      transmit <- rbinom(nrow(del2), 1, del2$finalProb)

      # Keep rows where transmission occurred
      del2 <- del2[which(transmit == 1), ]

      # Look up new ids if any transmissions occurred
      idsNewInf2 <- unique(del2$sus)
      nInf2 <- length(idsNewInf2)

      # Set new attributes for those newly infected
      if (nInf2 > 0) {
        dat$attr$status[idsNewInf2] <- "e"
        dat$attr$infTime[idsNewInf2] <- at
      }
    }

  }

  ## Save summary statistic for S->E flow
  dat$epi$se.flow[at] <- nInf1 + nInf2

  return(dat)
}

discord_edgelist_covid <- function(dat, nw = 1) {

  status <- dat$attr$status
  el <- dat$el[[nw]]

  del <- NULL
  if (nrow(el) > 0) {
    el <- el[sample(1:nrow(el)), , drop = FALSE]
    stat <- matrix(status[el], ncol = 2)
    isInf <- matrix(stat %in% "i", ncol = 2)
    isSus <- matrix(stat %in% "s", ncol = 2)
    SIpairs <- el[isSus[, 1] * isInf[, 2] == 1, , drop = FALSE]
    ISpairs <- el[isSus[, 2] * isInf[, 1] == 1, , drop = FALSE]
    pairs <- rbind(SIpairs, ISpairs[, 2:1])
    if (nrow(pairs) > 0) {
      sus <- pairs[, 1]
      inf <- pairs[, 2]
      del <- data.frame(sus, inf)
    }
  }

  return(del)
}


# Disease Progression Module ----------------------------------------------

progress_covid <- function(dat, at) {

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


  return(dat)
}


# Prevalence Module -------------------------------------------------------

prevalence_covid <- function(dat, at) {

  active <- dat$attr$active
  status <- dat$attr$status
  nsteps <- dat$control$nsteps

  var.names <- c("num", "i.num", "se.flow", "ei.flow", "ir.flow", "e.num", "r.num")
  if (at == 1) {
    for (i in 1:length(var.names)) {
      dat$epi[[var.names[i]]] <- rep(NA, nsteps)
    }
  }

  # Pop Size / Demog
  dat$epi$num[at] <- sum(active == 1)
  dat$epi$i.num[at] <- sum(active == 1 & status == "i")
  dat$epi$e.num[at] <- sum(active == 1 & status == "e")
  dat$epi$r.num[at] <- sum(active == 1 & status == "r")

  return(dat)
}
