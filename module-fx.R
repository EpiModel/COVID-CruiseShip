
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

  # Pull in attributes on network
  nwattr.all <- names(nw[[1]][["val"]][[1]])
  nwattr.use <- nwattr.all[!nwattr.all %in% c("na", "vertex.names")]
  for (i in seq_along(nwattr.use)) {
    dat$attr[[nwattr.use[i]]] <- get.vertex.attribute(nw[[1]], nwattr.use[i])
  }

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

  e.num.pass <- dat$init$e.num.pass
  e.num.crew <- dat$init$e.num.crew

  type <- dat$attr$type
  active <- dat$attr$active
  num <- sum(dat$attr$active)

  ## Disease status
  status <- rep("s", num)
  if (e.num.pass > 0) {
    status[sample(which(active == 1 & type == "p"), size = e.num.pass)] <- "e"
  }
  if (e.num.crew > 0) {
    status[sample(which(active == 1 & type == "c"), size = e.num.crew)] <- "e"
  }

  dat$attr$status <- status
  dat$attr$active <- rep(1, length(status))
  dat$attr$entrTime <- rep(1, length(status))
  dat$attr$exitTime <- rep(NA, length(status))

  # Infection Time
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

  dat$el[[1]] <- tergmLite::simulate_network(p = dat$p[[1]],
                                             el = dat$el[[1]],
                                             coef.form = nwparam1$coef.form,
                                             coef.diss = nwparam1$coef.diss$coef.adj,
                                             save.changes = FALSE)


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

  ## Find infected nodes ##
  idsInf <- which(active == 1 & status == "i")
  nActive <- sum(active == 1)
  nElig <- length(idsInf)

  ## Initialize default incidence at 0 ##
  nInf.PtoP <- 0
  nInf.PtoC <- 0
  nInf.CtoP <- 0
  nInf.CtoC <- 0

  # Pass/Pass Contacts
  if (length(idsInf) > 0) {

    ## Look up discordant edgelist ##
    del.PP <- discord_edgelist_covid(dat, nw = 1, contact.type = NULL)

    ## If any discordant pairs, proceed ##
    if (!(is.null(del.PP))) {

      ## Parameters ##
      inf.prob <- dat$param$inf.prob.pp
      act.rate <- dat$param$act.rate.pp

      inf.prob.pp.inter.rr <- dat$param$inf.prob.pp.inter.rr
      inf.prob.pp.inter.time <- dat$param$inf.prob.pp.inter.time

      # Set parameters on discordant edgelist data frame
      del.PP$transProb <- inf.prob
      if (at >= inf.prob.pp.inter.time) {
        del.PP$transProb <- del.PP$transProb * inf.prob.pp.inter.rr
      }
      del.PP$actRate <- act.rate
      del.PP$finalProb <- 1 - (1 - del.PP$transProb)^del.PP$actRate

      # Stochastic transmission process
      transmit <- rbinom(nrow(del.PP), 1, del.PP$finalProb)

      # Keep rows where transmission occurred
      del.PP <- del.PP[which(transmit == 1), ]

      # Look up new ids if any transmissions occurred
      idsNewInf.PtoP <- unique(del.PP$sus)
      nInf.PtoP <- length(idsNewInf.PtoP)

      # Set new attributes for those newly infected
      if (nInf.PtoP > 0) {
        dat$attr$status[idsNewInf.PtoP] <- "e"
        dat$attr$infTime[idsNewInf.PtoP] <- at
      }
    }

    # Pass/Crew Contacts
    del.PC <- discord_edgelist_covid(dat, nw = 2, contact.type = "pass.crew")
    if (!(is.null(del.PC))) {

      ## Parameters ##
      inf.prob <- dat$param$inf.prob.pc
      act.rate <- dat$param$act.rate.pc

      inf.prob.pc.inter.rr <- dat$param$inf.prob.pc.inter.rr
      inf.prob.pc.inter.time <- dat$param$inf.prob.pc.inter.time

      # Set parameters on discordant edgelist data frame
      del.PC$transProb <- inf.prob
      if (at >= inf.prob.pc.inter.time) {
        del.PC$transProb <- del.PC$transProb * inf.prob.pc.inter.rr
      }
      del.PC$actRate <- act.rate
      del.PC$finalProb <- 1 - (1 - del.PC$transProb)^del.PC$actRate

      # Stochastic transmission process
      transmit <- rbinom(nrow(del.PC), 1, del.PC$finalProb)

      # Keep rows where transmission occurred
      del.PC <- del.PC[which(transmit == 1), ]

      # New transmissions by direction
      idsNewInf.CtoP <- unique(del.PC$sus[dat$attr$type[del.PC$sus] == "p"])
      nInf.CtoP <- length(idsNewInf.CtoP)

      idsNewInf.PtoC <- unique(del.PC$sus[dat$attr$type[del.PC$sus] == "c"])
      nInf.PtoC <- length(idsNewInf.PtoC)

      # Either direction
      idsNewInf.PC <- union(idsNewInf.CtoP, idsNewInf.PtoC)

      # Set new attributes for those newly infected
      if ((nInf.CtoP + nInf.PtoC) > 0) {
        dat$attr$status[idsNewInf.PC] <- "e"
        dat$attr$infTime[idsNewInf.PC] <- at
      }
    }

    # Crew/Crew Contacts
    del.CC <- discord_edgelist_covid(dat, nw = 2, contact.type = "crew.crew")
    if (!(is.null(del.CC))) {

      ## Parameters ##
      inf.prob <- dat$param$inf.prob.cc
      act.rate <- dat$param$act.rate.cc

      inf.prob.cc.inter.rr <- dat$param$inf.prob.cc.inter.rr
      inf.prob.cc.inter.time <- dat$param$inf.prob.cc.inter.time

      # Set parameters on discordant edgelist data frame
      del.CC$transProb <- inf.prob
      if (at >= inf.prob.cc.inter.time) {
        del.CC$transProb <- del.CC$transProb * inf.prob.cc.inter.rr
      }
      del.CC$actRate <- act.rate
      del.CC$finalProb <- 1 - (1 - del.CC$transProb)^del.CC$actRate

      # Stochastic transmission process
      transmit <- rbinom(nrow(del.CC), 1, del.CC$finalProb)

      # Keep rows where transmission occurred
      del.CC <- del.CC[which(transmit == 1), ]

      # Look up new ids if any transmissions occurred
      idsNewInf.CtoC <- unique(del.CC$sus)
      nInf.CtoC <- length(idsNewInf.CtoC)

      # Set new attributes for those newly infected
      if (nInf.CtoC > 0) {
        dat$attr$status[idsNewInf.CtoC] <- "e"
        dat$attr$infTime[idsNewInf.CtoC] <- at
      }
    }

  }

  ## Save summary statistic for S->E flow
  dat$epi$se.flow[at] <- nInf.PtoP + nInf.PtoC + nInf.CtoP + nInf.CtoC
  dat$epi$se.pp.flow[at] <- nInf.PtoP
  dat$epi$se.pc.flow[at] <- nInf.PtoC
  dat$epi$se.cp.flow[at] <- nInf.CtoP
  dat$epi$se.cc.flow[at] <- nInf.CtoC

  return(dat)
}

discord_edgelist_covid <- function(dat, nw = 1, contact.type = NULL) {

  status <- dat$attr$status
  type <- dat$attr$type
  el <- dat$el[[nw]]

  if (!is.null(contact.type)) {
    el.type <- matrix(type[el], ncol = 2)
    if (contact.type == "pass.crew") {
      subset.ids <- c(which(el.type[, 1] == "p" & el.type[, 2] == "c"),
                      which(el.type[, 1] == "c" & el.type[, 2] == "p"))
      el <- el[subset.ids, , drop = FALSE]
    }
    if (contact.type == "crew.crew") {
      subset.ids <- which(el.type[, 1] == "c" & el.type[, 2] == "c")
      el <- el[subset.ids, , drop = FALSE]
    }
  }

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
  type <- dat$attr$type

  nsteps <- dat$control$nsteps

  # Initialize Outputs
  var.names <- c("num", "s.num", "e.num", "i.num", "r.num",
                 "i.pass.num", "i.crew.num",
                 "se.flow", "ei.flow", "ir.flow", "d.flow",
                 "se.pp.flow", "se.pc.flow", "se.cp.flow", "se.cc.flow",
                 "meanAge")
  if (at == 1) {
    for (i in 1:length(var.names)) {
      dat$epi[[var.names[i]]] <- rep(0, nsteps)
    }
  }

  # Update Outputs
  dat$epi$num[at] <- sum(active == 1)

  dat$epi$s.num[at] <- sum(active == 1 & status == "s")
  dat$epi$e.num[at] <- sum(active == 1 & status == "e")
  dat$epi$i.num[at] <- sum(active == 1 & status == "i")
  dat$epi$r.num[at] <- sum(active == 1 & status == "r")

  dat$epi$i.pass.num[at] <- sum(active == 1 & status == "i" & type == "p")
  dat$epi$i.crew.num[at] <- sum(active == 1 & status == "i" & type == "c")

  dat$epi$meanAge[at] <- mean(dat$attr$age, na.rm = TRUE)

  return(dat)
}


# Aging Module ------------------------------------------------------------

aging_covid <- function(dat, at) {

  dat$attr$age <- dat$attr$age + 1/365

  return(dat)
}


# Mortality Module --------------------------------------------------------

dfunc_covid <- function(dat, at) {

  ## Attributes ##
  active <- dat$attr$active
  age <- dat$attr$age
  status <- dat$attr$status

  ## Parameters ##
  mort.rates <- dat$param$mort.rates
  mort.dis.mult <- dat$param$mort.dis.mult

  idsElig <- which(active == 1)
  nElig <- length(idsElig)
  nDeaths <- 0

  if (nElig > 0) {

    whole_ages_of_elig <- pmin(ceiling(age[idsElig]), 86)
    death_rates_of_elig <- mort.rates[whole_ages_of_elig]

    idsElig.inf <- which(status[idsElig] == "i")
    death_rates_of_elig[idsElig.inf] <- death_rates_of_elig[idsElig.inf] * mort.dis.mult

    vecDeaths <- which(rbinom(nElig, 1, death_rates_of_elig) == 1)
    idsDeaths <- idsElig[vecDeaths]
    nDeaths <- length(idsDeaths)

    if (nDeaths > 0) {
      dat$attr$active[idsDeaths] <- 0
      inactive <- which(dat$attr$active == 0)
      dat$attr <- deleteAttr(dat$attr, inactive)
      for (i in 1:length(dat$el)) {
        dat$el[[i]] <- delete_vertices(dat$el[[i]], inactive)
      }
    }
  }

  ## Summary statistics ##
  dat$epi$d.flow[at] <- nDeaths

  return(dat)
}
