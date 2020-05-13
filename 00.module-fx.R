
##
## COVID-19 Cruise Ship Network Model
## Model Functions
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
  for (i in 1:length(x)) {
    dat$nw[[i]] <- simulate(x[[i]]$fit, basis = x[[i]]$fit$newnetwork)
  }
  nw <- dat$nw

  # Pull Network parameters
  dat$nwparam <- list()
  for (i in 1:length(x)) {
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
  clinical <- rep(NA, length(status))
  statusTime <- rep(NA, length(status))
  statusTime[idsInf] <- 1
  dxStatus <- rep(0, length(status))
  transmissions <- rep(0, length(status))

  dat$attr$statusTime <- statusTime
  dat$attr$infTime <- infTime
  dat$attr$clinical <- clinical
  dat$attr$dxStatus <- dxStatus
  dat$attr$transmissions <- transmissions

  return(dat)
}


# Network Resimulation Module ---------------------------------------------

resim_nets_covid <- function(dat, at) {

  ## Edges correction
  dat <- edges_correct_covid(dat, at)

  if (at < dat$param$network.lockdown.time) {
    nets <- 1:3
  } else {
    nets <- 4:6
  }

  # Network Resimulation
  for (i in nets) {
    nwparam <- EpiModel::get_nwparam(dat, network = i)
    isTERGM <- ifelse(nwparam$coef.diss$duration > 1, TRUE, FALSE)
    dat <- tergmLite::updateModelTermInputs(dat, network = i)
    if (isTERGM == TRUE) {
      dat$el[[i]] <- tergmLite::simulate_network(p = dat$p[[i]],
                                                 el = dat$el[[i]],
                                                 coef.form = nwparam$coef.form,
                                                 coef.diss = nwparam$coef.diss$coef.adj,
                                                 save.changes = FALSE)
    } else {
      dat$el[[i]] <- tergmLite::simulate_ergm(p = dat$p[[i]],
                                              el = dat$el[[i]],
                                              coef = nwparam$coef.form)
    }
  }

  if (dat$control$save.nwstats == TRUE) {
    dat <- calc_nwstats_covid(dat, at)
  }

  return(dat)
}

edges_correct_covid <- function(dat, at) {

  old.num <- dat$epi$num[at - 1]
  new.num <- sum(dat$attr$active == 1, na.rm = TRUE)
  adjust <- log(old.num) - log(new.num)

  for (i in 1:length(dat$nwparam)) {
    coef.form1 <- get_nwparam(dat, network = i)$coef.form
    coef.form1[1] <- coef.form1[1] + adjust
    dat$nwparam[[i]]$coef.form <- coef.form1
  }

  return(dat)
}

calc_nwstats_covid <- function(dat, at) {

  for (nw in 1:length(dat$el)) {
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
  infTime <- dat$attr$infTime
  statusTime <- dat$attr$statusTime
  transmissions <- dat$attr$transmissions

  ## Find infected nodes ##
  idsInf <- which(active == 1 & status %in% c("a", "ic", "ip"))
  nActive <- sum(active == 1)
  nElig <- length(idsInf)

  ## Common Parameters ##
  inf.prob.a.rr <- dat$param$inf.prob.a.rr

  act.rate.dx.inter.rr <- dat$param$act.rate.dx.inter.rr
  act.rate.dx.inter.time <- dat$param$act.rate.dx.inter.time
  act.rate.sympt.inter.rr <- dat$param$act.rate.sympt.inter.rr
  act.rate.sympt.inter.time <- dat$param$act.rate.sympt.inter.time

  network.lockdown.time <- dat$param$network.lockdown.time
  if (at < network.lockdown.time) {
    nets <- 1:3
  } else {
    nets <- 4:6
  }

  ## Initialize default incidences at 0 ##
  nInf.PtoP <- 0
  nInf.PtoC <- 0
  nInf.CtoP <- 0
  nInf.CtoC <- 0

  # Pass/Pass Contacts
  if (length(idsInf) > 0) {

    ## Look up discordant edgelist ##
    del.PP <- discord_edgelist_covid(dat, nw = nets[1])

    ## If any discordant pairs, proceed ##
    if (!(is.null(del.PP))) {

      ## Parameters ##
      inf.prob <- dat$param$inf.prob.pp
      act.rate <- dat$param$act.rate.pp
      inf.prob.pp.inter.rr <- dat$param$inf.prob.pp.inter.rr
      inf.prob.pp.inter.time <- dat$param$inf.prob.pp.inter.time
      act.rate.pp.inter.rr <- dat$param$act.rate.pp.inter.rr
      act.rate.pp.inter.time <- dat$param$act.rate.pp.inter.time

      # Set parameters on discordant edgelist data frame
      del.PP$transProb <- inf.prob
      del.PP$transProb[del.PP$stat == "a"] <- del.PP$transProb[del.PP$stat == "a"] *
                                              inf.prob.a.rr
      if (at >= inf.prob.pp.inter.time) {
        del.PP$transProb <- del.PP$transProb * inf.prob.pp.inter.rr
      }
      del.PP$actRate <- act.rate
      if (at >= act.rate.pp.inter.time) {
        del.PP$actRate <- del.PP$actRate * act.rate.pp.inter.rr
      }
      if (at >= act.rate.dx.inter.time) {
        del.PP$actRate[del.PP$dx == 1] <- del.PP$actRate[del.PP$dx == 1] *
                                          act.rate.dx.inter.rr
      }
      if (at >= act.rate.sympt.inter.time) {
        del.PP$actRate[del.PP$stat == "ic"] <- del.PP$actRate[del.PP$stat == "ic"] *
                                               act.rate.sympt.inter.rr
      }
      del.PP$finalProb <- 1 - (1 - del.PP$transProb)^del.PP$actRate

      # Stochastic transmission process
      transmit <- rbinom(nrow(del.PP), 1, del.PP$finalProb)

      # Keep rows where transmission occurred
      del.PP <- del.PP[which(transmit == 1), ]

      # Look up new ids if any transmissions occurred
      idsNewInf.PtoP <- unique(del.PP$sus)
      nInf.PtoP <- length(idsNewInf.PtoP)
      transIds <- del.PP$inf

      # Set new attributes for those newly infected
      if (nInf.PtoP > 0) {
        dat$attr$status[idsNewInf.PtoP] <- "e"
        dat$attr$infTime[idsNewInf.PtoP] <- at
        dat$attr$statusTime[idsNewInf.PtoP] <- at
        dat$attr$transmissions[transIds] <- transmissions[transIds] + 1
      }
    }

    # Crew/Crew Contacts
    del.CC <- discord_edgelist_covid(dat, nw = nets[2])
    if (!(is.null(del.CC))) {

      ## Parameters ##
      inf.prob <- dat$param$inf.prob.cc
      act.rate <- dat$param$act.rate.cc
      inf.prob.cc.inter.rr <- dat$param$inf.prob.cc.inter.rr
      inf.prob.cc.inter.time <- dat$param$inf.prob.cc.inter.time
      act.rate.cc.inter.rr <- dat$param$act.rate.cc.inter.rr
      act.rate.cc.inter.time <- dat$param$act.rate.cc.inter.time

      # Set parameters on discordant edgelist data frame
      del.CC$transProb <- inf.prob
      del.CC$transProb[del.CC$stat == "a"] <- del.CC$transProb[del.CC$stat == "a"] *
                                              inf.prob.a.rr
      if (at >= inf.prob.cc.inter.time) {
        del.CC$transProb <- del.CC$transProb * inf.prob.cc.inter.rr
      }
      del.CC$actRate <- act.rate
      if (at >= act.rate.cc.inter.time) {
        del.CC$actRate <- del.CC$actRate * act.rate.cc.inter.rr
      }
      if (at >= act.rate.dx.inter.time) {
        del.CC$actRate[del.CC$dx == 1] <- del.CC$actRate[del.CC$dx == 1] *
                                          act.rate.dx.inter.rr
      }
      if (at >= act.rate.sympt.inter.time) {
        del.CC$actRate[del.CC$stat == "ic"] <- del.CC$actRate[del.CC$stat == "ic"] *
                                               act.rate.sympt.inter.rr
      }
      del.CC$finalProb <- 1 - (1 - del.CC$transProb)^del.CC$actRate

      # Stochastic transmission process
      transmit <- rbinom(nrow(del.CC), 1, del.CC$finalProb)

      # Keep rows where transmission occurred
      del.CC <- del.CC[which(transmit == 1), ]

      # Look up new ids if any transmissions occurred
      idsNewInf.CtoC <- unique(del.CC$sus)
      nInf.CtoC <- length(idsNewInf.CtoC)
      transIds <- del.CC$inf

      # Set new attributes for those newly infected
      if (nInf.CtoC > 0) {
        dat$attr$status[idsNewInf.CtoC] <- "e"
        dat$attr$infTime[idsNewInf.CtoC] <- at
        dat$attr$statusTime[idsNewInf.CtoC] <- at
        dat$attr$transmissions[transIds] <- transmissions[transIds] + 1
      }
    }

    # Pass/Crew Contacts
    del.PC <- discord_edgelist_covid(dat, nw = nets[3])
    if (!(is.null(del.PC))) {

      ## Parameters ##
      inf.prob <- dat$param$inf.prob.pc
      act.rate <- dat$param$act.rate.pc
      inf.prob.pc.inter.rr <- dat$param$inf.prob.pc.inter.rr
      inf.prob.pc.inter.time <- dat$param$inf.prob.pc.inter.time
      act.rate.pc.inter.rr <- dat$param$act.rate.pc.inter.rr
      act.rate.pc.inter.time <- dat$param$act.rate.pc.inter.time

      # Set parameters on discordant edgelist data frame
      del.PC$transProb <- inf.prob
      del.PC$transProb[del.PC$stat == "a"] <- del.PC$transProb[del.PC$stat == "a"] *
                                              inf.prob.a.rr
      if (at >= inf.prob.pc.inter.time) {
        del.PC$transProb <- del.PC$transProb * inf.prob.pc.inter.rr
      }
      del.PC$actRate <- act.rate
      if (at >= act.rate.pc.inter.time) {
        del.PC$actRate <- del.PC$actRate * act.rate.pc.inter.rr
      }
      if (at >= act.rate.dx.inter.time) {
        del.PC$actRate[del.PP$dx == 1] <- del.PC$actRate[del.PC$dx == 1] *
                                          act.rate.dx.inter.rr
      }
      if (at >= act.rate.sympt.inter.time) {
        del.PC$actRate[del.PC$stat == "ic"] <- del.PC$actRate[del.PC$stat == "ic"] *
                                               act.rate.sympt.inter.rr
      }
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
      transIds <- del.PC$inf

      # Set new attributes for those newly infected
      if ((nInf.CtoP + nInf.PtoC) > 0) {
        dat$attr$status[idsNewInf.PC] <- "e"
        dat$attr$infTime[idsNewInf.PC] <- at
        dat$attr$statusTime[idsNewInf.PC] <- at
        dat$attr$transmissions[transIds] <- transmissions[transIds] + 1
      }
    }
  }


  ## Save summary statistics for S->E flow
  dat$epi$se.flow[at] <- nInf.PtoP + nInf.PtoC + nInf.CtoP + nInf.CtoC
  dat$epi$se.pp.flow[at] <- nInf.PtoP
  dat$epi$se.pc.flow[at] <- nInf.PtoC
  dat$epi$se.cp.flow[at] <- nInf.CtoP
  dat$epi$se.cc.flow[at] <- nInf.CtoC
  dat$epi$Rt[at] <- mean(transmissions[status %in% c("a", "ip", "ic", "r")])
  return(dat)
}

discord_edgelist_covid <- function(dat, nw = 1) {

  status <- dat$attr$status
  dxStatus <- dat$attr$dxStatus
  type <- dat$attr$type

  el <- dat$el[[nw]]

  del <- NULL
  if (nrow(el) > 0) {
    el <- el[sample(1:nrow(el)), , drop = FALSE]
    stat <- matrix(status[el], ncol = 2)
    isInf <- matrix(stat %in% c("a", "ic", "ip"), ncol = 2)
    isSus <- matrix(stat %in% "s", ncol = 2)
    SIpairs <- el[isSus[, 1] * isInf[, 2] == 1, , drop = FALSE]
    ISpairs <- el[isSus[, 2] * isInf[, 1] == 1, , drop = FALSE]
    pairs <- rbind(SIpairs, ISpairs[, 2:1])
    if (nrow(pairs) > 0) {
      sus <- pairs[, 1]
      inf <- pairs[, 2]
      del <- data.frame(sus = sus, inf = inf, stat = status[inf], dx = dxStatus[inf])
    }
  }

  return(del)
}


# Disease Progression Module ----------------------------------------------

progress_covid <- function(dat, at) {

  ## Attributes
  active <- dat$attr$active
  status <- dat$attr$status
  statusTime <- dat$attr$statusTime
  infTime <- dat$attr$infTime
  clinical <- dat$attr$clinical
  age <- dat$attr$age

  ## Parameters
  prop.clinical <- dat$param$prop.clinical
  ea.rate <- dat$param$ea.rate
  ar.rate <- dat$param$ar.rate
  eip.rate <- dat$param$eip.rate
  ipic.rate <- dat$param$ipic.rate
  icr.rate <- dat$param$icr.rate

  ## Determine Subclinical (E to A) or Clinical (E to Ip to Ic) pathway
  ids.newInf <- which(active == 1 & status == "e" & statusTime <= at & is.na(clinical))
  num.newInf <- length(ids.newInf)
  if (num.newInf > 0) {
    age.group <- pmin((round(age[ids.newInf], -1)/10) + 1, 8)
    prop.clin.vec <- prop.clinical[age.group]
    if (any(is.na(prop.clin.vec))) stop("error in prop.clin.vec")
    vec.new.clinical <- rbinom(num.newInf, 1, prop.clinical)
    clinical[ids.newInf] <- vec.new.clinical
  }
  if (any(status == "e" & is.na(clinical))) browser()

  ## Subclinical Pathway
  # E to A: latent move to asymptomatic infectious
  num.new.EtoA <- 0
  ids.Es <- which(active == 1 & status == "e" & statusTime < at & clinical == 0)
  num.Es <- length(ids.Es)
  if (num.Es > 0) {
    vec.new.A <- which(rbinom(num.Es, 1, ea.rate) == 1)
    if (length(vec.new.A) > 0) {
      ids.new.A <- ids.Es[vec.new.A]
      num.new.EtoA <- length(ids.new.A)
      status[ids.new.A] <- "a"
      statusTime[ids.new.A] <- at
    }
  }

  # A to R: asymptomatic infectious move to recovered
  num.new.AtoR <- 0
  ids.A <- which(active == 1 & status == "a" & statusTime < at & clinical == 0)
  num.A <- length(ids.A)
  if (num.A > 0) {
    vec.new.R <- which(rbinom(num.A, 1, ar.rate) == 1)
    if (length(vec.new.R) > 0) {
      ids.new.R <- ids.A[vec.new.R]
      num.new.AtoR <- length(ids.new.R)
      status[ids.new.R] <- "r"
      statusTime[ids.new.R] <- at
    }
  }

  ## Clinical Pathway
  # E to Ip: latent move to preclinical infectious
  num.new.EtoIp <- 0
  ids.Ec <- which(active == 1 & status == "e" & statusTime < at & clinical == 1)
  num.Ec <- length(ids.Ec)
  if (num.Ec > 0) {
    vec.new.Ip <- which(rbinom(num.Ec, 1, eip.rate) == 1)
    if (length(vec.new.Ip) > 0) {
      ids.new.Ip <- ids.Ec[vec.new.Ip]
      num.new.EtoIp <- length(ids.new.Ip)
      status[ids.new.Ip] <- "ip"
      statusTime[ids.new.Ip] <- at
    }
  }

  # Ip to Ic: preclinical infectious move to clinical infectious
  num.new.IptoIc <- 0
  ids.Ip <- which(active == 1 & status == "ip" & statusTime < at & clinical == 1)
  num.Ip <- length(ids.Ip)
  if (num.Ip > 0) {
    vec.new.Ic <- which(rbinom(num.Ip, 1, ipic.rate) == 1)
    if (length(vec.new.Ic) > 0) {
      ids.new.Ic <- ids.Ip[vec.new.Ic]
      num.new.IptoIc <- length(ids.new.Ic)
      status[ids.new.Ic] <- "ic"
      statusTime[ids.new.Ic] <- at
    }
  }

  # Ic to R: clinical infectious move to recovered (if not mortality first)
  num.new.IctoR <- 0
  ids.Ic <- which(active == 1 & status == "ic" & statusTime < at & clinical == 1)
  num.Ic <- length(ids.Ic)
  if (num.Ic > 0) {
    vec.new.R <- which(rbinom(num.Ic, 1, icr.rate) == 1)
    if (length(vec.new.R) > 0) {
      ids.new.R <- ids.Ic[vec.new.R]
      num.new.IctoR <- length(ids.new.R)
      status[ids.new.R] <- "r"
      statusTime[ids.new.R] <- at
    }
  }

  ## Save updated status attribute
  dat$attr$status <- status
  dat$attr$statusTime <- statusTime
  dat$attr$clinical <- clinical

  ## Save summary statistics
  dat$epi$ea.flow[at] <- num.new.EtoA
  dat$epi$ar.flow[at] <- num.new.AtoR

  dat$epi$eip.flow[at] <- num.new.EtoIp
  dat$epi$ipic.flow[at] <- num.new.IptoIc
  dat$epi$icr.flow[at] <- num.new.IctoR

  return(dat)
}


# Diagnosis Module --------------------------------------------------------

dx_covid <- function(dat, at) {

  active <- dat$attr$active
  status <- dat$attr$status
  type <- dat$attr$type
  dxStatus <- dat$attr$dxStatus

  dx.start <- dat$param$dx.start
  dx.rate.pass <- dat$param$dx.rate.pass
  dx.rate.crew <- dat$param$dx.rate.crew
  dx.elig.status <- dat$param$dx.elig.status

  idsElig <- which(active == 1 & dxStatus == 0 & status %in% dx.elig.status)
  nElig <- length(idsElig)
  nDx <- 0
  nDx.pos <- 0
  nDx.pos.sympt <- 0

  if (at >= dx.start & nElig > 0) {
    dx.rates <- ifelse(type[idsElig] == "p", dx.rate.pass, dx.rate.crew)
    vecDx <- which(rbinom(nElig, 1, dx.rates) == 1)
    idsDx <- idsElig[vecDx]
    nDx <- length(idsDx)
    nDx.pos <- intersect(idsDx, which(status %in% c("e", "a", "ip", "ic")))
    nDx.pos.sympt <- intersect(idsDx, which(status == "ic"))
    if (nDx > 0) {
      dxStatus[idsDx] <- 1
    }
  }

  ## Replace attr
  dat$attr$dxStatus <- dxStatus

  ## Summary statistics ##
  dat$epi$nDx[at] <- nDx
  dat$epi$nDx.pos[at] <- nDx.pos
  dat$epi$nDx.pos.sympt[at] <- nDx.pos.sympt

  return(dat)
}


# Prevalence Module -------------------------------------------------------

prevalence_covid <- function(dat, at) {

  active <- dat$attr$active
  status <- dat$attr$status
  type <- dat$attr$type

  nsteps <- dat$control$nsteps

  # Initialize Outputs
  var.names <- c("num", "s.num", "e.num", "a.num", "ip.num", "ic.num", "r.num",
                 "i.pass.num", "i.crew.num",
                 "se.flow", "ea.flow", "ar.flow", "Rt",
                 "eip.flow", "ipic.flow", "icr.flow",
                 "d.flow", "exit.flow", "nDx", "nDx.pos", "nDx.pos.sympt",
                 "se.pp.flow", "se.pc.flow", "se.cp.flow", "se.cc.flow",
                 "meanAge", "meanClinic")
  if (at == 1) {
    for (i in 1:length(var.names)) {
      dat$epi[[var.names[i]]] <- rep(0, nsteps)
    }
  }

  # Update Outputs
  dat$epi$num[at] <- sum(active == 1)

  dat$epi$s.num[at] <- sum(active == 1 & status == "s")
  dat$epi$e.num[at] <- sum(active == 1 & status == "e")
  dat$epi$a.num[at] <- sum(active == 1 & status == "a")
  dat$epi$ip.num[at] <- sum(active == 1 & status == "ip")
  dat$epi$ic.num[at] <- sum(active == 1 & status == "ic")
  dat$epi$r.num[at] <- sum(active == 1 & status == "r")

  dat$epi$i.pass.num[at] <- sum(active == 1 & status %in% c("ip", "ic", "a") & type == "p")
  dat$epi$i.crew.num[at] <- sum(active == 1 & status %in% c("ip", "ic", "a") & type == "c")

  dat$epi$meanAge[at] <- mean(dat$attr$age, na.rm = TRUE)
  dat$epi$meanClinic[at] <- mean(dat$attr$clinical, na.rm = TRUE)

  return(dat)
}


# Aging Module ------------------------------------------------------------

aging_covid <- function(dat, at) {

  dat$attr$age <- dat$attr$age + 1/365

  return(dat)
}


# Mortality Module --------------------------------------------------------

deaths_covid <- function(dat, at) {

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

    idsElig.inf <- which(status[idsElig] == "ic")
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


# Offloading Passengers ---------------------------------------------------

offload_covid <- function(dat, at) {

  ## Attributes ##
  active <- dat$attr$active
  age <- dat$attr$age
  status <- dat$attr$status
  dxStatus <- dat$attr$dxStatus
  type <- dat$attr$type

  ## Parameters ##
  exit.rate.pass <- dat$param$exit.rate.pass
  exit.rate.crew <- dat$param$exit.rate.crew

  exit.elig.status <- dat$param$exit.elig.status
  require.dx <- dat$param$exit.require.dx

  idsElig <- which(active == 1 & status %in% exit.elig.status)
  if (require.dx == TRUE) {
    idsElig <- intersect(idsElig, which(dxStatus == 1))
  }
  nElig <- length(idsElig)
  nExits <- 0

  if (nElig > 0) {
    exit.rates <- ifelse(type[idsElig] == "p", exit.rate.pass, exit.rate.crew)
    vecExits <- which(rbinom(nElig, 1, exit.rates) == 1)
    idsExits <- idsElig[vecExits]
    nExits <- length(idsExits)

    if (nExits > 0) {
      active[idsExits] <- 0
      inactive <- which(active == 0)
      dat$attr <- deleteAttr(dat$attr, inactive)
      for (i in 1:length(dat$el)) {
        dat$el[[i]] <- delete_vertices(dat$el[[i]], inactive)
      }
    }
  }

  ## Summary statistics ##
  dat$epi$exit.flow[at] <- nExits

  return(dat)
}
