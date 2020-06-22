

calc_quants_prev <- function(x, var, at = 520, mult = 1, round = 1, qnt.low = 0.025, qnt.high = 0.975) {
  if (is.null(x$epi[[var]])) {
    stop("var ", var, " does not exist on x", call. = FALSE)
  }
  out <- as.numeric(x$epi[[var]][at, ])*mult
  out <- quantile(out, c(0.5, qnt.low, qnt.high), names = FALSE)
  format <- paste0("%.", round, "f")
  out <- sprintf(format, out)
  out <- paste0(out[1], " (", out[2], ", ", out[3], ")")
  return(out)
}

calc_quants_ir <- function(x, var, qnt.low = 0.025, qnt.high = 0.975, round = 1) {
  if (is.null(x$epi[[var]])) {
    stop("var ", var, " does not exist on x", call. = FALSE)
  }
  out <- as.numeric(colMeans(tail(x$epi[[var]], 52)))
  out <- quantile(out, c(0.5, qnt.low, qnt.high), names = FALSE)
  out <- sprintf("%.2f", out)
  out <- paste0(out[1], " (", out[2], ", ", out[3], ")")
  return(out)
}

calc_quants_ci <- function(x, var, qnt.low = 0.25, qnt.high = 0.75, round = 1) {
  if (is.null(x$epi[[var]])) {
    stop("var ", var, " does not exist on x", call. = FALSE)
  }
  out <- as.numeric(colSums(x$epi[[var]], 52))
  out <- quantile(out, c(0.5, qnt.low, qnt.high), names = FALSE)
  format <- paste0("%.", round, "f")
  out <- sprintf(format, out)
  out <- paste0(out[1], " (", out[2], ", ", out[3], ")")
  return(out)
}


calc_quants_hr <- function(x.base, x.comp, var, qnt.low = 0.025, qnt.high = 0.975, nsims = 1000) {
  vec <- rep(NA, nsims)
  numer.start <- unname(colMeans(tail(x.comp$epi[[var]], 52)))
  denom.start <- unname(colMeans(tail(x.base$epi[[var]], 52)))
  for (i in 1:nsims) {
    numer <- sample(numer.start)
    denom <- sample(denom.start)
    vec[i] <- median(numer/denom, na.rm = TRUE)
  }
  out <- quantile(vec, c(0.5, qnt.low, qnt.high), names = FALSE)
  out <- sprintf("%.2f", out)
  out <- paste0(out[1], " (", out[2], ", ", out[3], ")")
  return(out)
}


calc_quants_ia <- function(x.base, x.comp, var, qnt.low = 0.025, qnt.high = 0.975, nsims = 1000) {
  vec.nia <- rep(NA, nsims)
  vec.pia <- rep(NA, nsims)
  incid.comp.start <- unname(colSums(x.comp$epi[[var]]))
  incid.base.start <- unname(colSums(x.base$epi[[var]]))
  for (i in 1:nsims) {
    incid.comp <- sample(incid.comp.start)
    incid.base <- sample(incid.base.start)
    vec.nia[i] <- median(incid.base - incid.comp)
    vec.pia[i] <- median((incid.base - incid.comp) / incid.base)
  }
  nia <- quantile(vec.nia, c(0.5, qnt.low, qnt.high), names = FALSE)
  nia <- sprintf("%.1f", nia)
  nia <- paste0(nia[1], " (", nia[2], ", ", nia[3], ")")

  pia <- quantile(vec.pia, c(0.5, qnt.low, qnt.high), names = FALSE, na.rm = TRUE)*100
  pia <- sprintf("%.1f", pia)
  pia <- paste0(pia[1], " (", pia[2], ", ", pia[3], ")")

  out <- list()
  out$nia <- nia
  out$pia <- pia

  return(out)
}

epi_stats <- function(sim.base,
                      sim.comp = NULL,
                      qnt.low = 0.025,
                      qnt.high = 0.975,
                      table.num) {

  if (is.null(sim.comp)) {
    x <- sim.base
  } else {
    x <- sim.comp
    ia <- calc_quants_ia(sim.base, sim.comp, "se.flow", qnt.low, qnt.high)
    da <- calc_quants_ia(sim.base, sim.comp, "d.ic.flow", qnt.low, qnt.high)
    ia.pp <- calc_quants_ia(sim.base, sim.comp, "se.pp.flow", qnt.low, qnt.high)
    ia.pc <- calc_quants_ia(sim.base, sim.comp, "se.pc.flow", qnt.low, qnt.high)
    ia.cp <- calc_quants_ia(sim.base, sim.comp, "se.cp.flow", qnt.low, qnt.high)
    ia.cc <- calc_quants_ia(sim.base, sim.comp, "se.cc.flow", qnt.low, qnt.high)
  }

  # incidence rate
  ci <- calc_quants_ci(x, "se.flow", qnt.low, qnt.high)
  ci.pp <- calc_quants_ci(x, "se.pp.flow", qnt.low, qnt.high)
  ci.pc <- calc_quants_ci(x, "se.pc.flow", qnt.low, qnt.high)
  ci.cp <- calc_quants_ci(x, "se.cp.flow", qnt.low, qnt.high)
  ci.cc <- calc_quants_ci(x, "se.cc.flow", qnt.low, qnt.high)
  d <- calc_quants_ci(x, "d.ic.flow", qnt.low, qnt.high)

  # Table Output -------------------------------------------------

  if (table.num == 1) {
    if (is.null(sim.comp)) {
      dat <- cbind(ci, nia = NA, pia = NA,
                   d, nda = NA, pda = NA)
    } else {
      dat <- cbind(ci, nia = ia$nia, pia = ia$pia,
                   d, nda = da$nia, pda = da$pia)
    }
  }

  if (table.num == 2) {
    if (is.null(sim.comp)) {
      dat <- cbind(ci, pia = NA,
                   ci.pp, pia.pp = NA,
                   ci.pc, pia.pc = NA,
                   ci.cp, pia.cp = NA,
                   ci.cc, pia.cc = NA)
    } else {
      dat <- cbind(ci, pia = ia$pia,
                   ci.pp, pia.pp = ia.pp$pia,
                   ci.pc, pia.pc = ia.pc$pia,
                   ci.cp, pia.cp = ia.cp$pia,
                   ci.cc, pia.cc = ia.cc$pia)
    }
  }

  if (table.num == 4) {
    if (is.null(sim.comp)) {
      dat <- cbind(ci, nia = NA,
                   ci.pp, ci.pc, ci.cp, ci.cc,
                   d, nda = NA)
    } else {
      dat <- cbind(ci, nia = ia$nia,
                   ci.pp, ci.pc, ci.cp, ci.cc,
                   d, nda = da$nia)
    }
  }


  out <- as.data.frame(dat, stringsAsFactors = FALSE)

  return(out)
}

make_row <- function(x, table.num) {
  fn <- list.files(path = "analysis/dat/",
                   pattern = paste0("sim.n",as.character(x)), full.names = TRUE)
  load(fn)
  sim.comp <- sim
  out <- epi_stats(sim.base, sim.comp, table.num = table.num)
  cat("*")
  return(out)
}
