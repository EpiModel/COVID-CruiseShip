
abc <- readRDS("analysis/sim.sensitivityABC.10k.rds")

nsim <- abc$control$nsims
for (i in 1:nsim) {
  param <- c(
    abc$param$random.params.values$dx.rate.sympt[[i]][c(16, 21, 26)],
    abc$param$random.params.values$dx.rate.other[[i]][c(21, 26)],
    abc$param$random.params.values$inf.prob.pp[[i]],
    abc$param$random.params.values$act.rate.pp[[i]])
  out1 <- as.data.frame(abc, sim = i)
  out <- tail(out1$se.cuml, 1)
  if (i == 1) {
    df <- data.frame(dx.sympt.16 = param[1],
                     dx.sympt.21 = param[2],
                     dx.sympt.26 = param[3],
                     dx.other.21 = param[4],
                     dx.other.26 = param[5],
                     inf.prob = param[6],
                     act.rate = param[7],
                     incid = out)
  } else {
    tdf <- data.frame(dx.sympt.16 = param[1],
                     dx.sympt.21 = param[2],
                     dx.sympt.26 = param[3],
                     dx.other.21 = param[4],
                     dx.other.26 = param[5],
                     inf.prob = param[6],
                     act.rate = param[7],
                     incid = out)
    df <- rbind(df, tdf)
  }
}
head(df, 100)

plot(df$dx.sympt.16, df$incid)
hist(df$dx.sympt.16)

pdf("analysis/Fig-Sens1-Supp.pdf", height = 6, width = 10)
par(mfrow = c(1,3))
plot(jitter(df$dx.sympt.16, factor = 2000), df$incid, pch = 20, col = adjustcolor("black", alpha.f = 0.1,),
     xlab = "Parameter", ylab = "Cumulative Incidence", main = "Symptomatic Screening (Days 16-20)")
plot(jitter(df$dx.sympt.21, factor = 2000), df$incid, pch = 20, col = adjustcolor("black", alpha.f = 0.1,),
     xlab = "Parameter", ylab = "Cumulative Incidence", main = "Symptomatic Screening (Days 21-25)")
plot(jitter(df$dx.sympt.26, factor = 2000), df$incid, pch = 20, col = adjustcolor("black", alpha.f = 0.1,),
     xlab = "Parameter", ylab = "Cumulative Incidence", main = "Symptomatic Screening (Days 26-31)")
dev.off()

pdf("analysis/Fig-Sens2-Supp.pdf", height = 6, width = 10)
par(mfrow = c(1,2))
plot(jitter(df$dx.other.21, factor = 2000), df$incid, pch = 20, col = adjustcolor("black", alpha.f = 0.1,),
     xlab = "Parameter", ylab = "Cumulative Incidence", main = "Asymptomatic Screening (Days 21-25)")
plot(jitter(df$dx.other.26, factor = 2000), df$incid, pch = 20, col = adjustcolor("black", alpha.f = 0.1,),
     xlab = "Parameter", ylab = "Cumulative Incidence", main = "Asymptomatic Screening (Days 26-31)")
dev.off()

pdf("analysis/Fig-Sens3-Supp.pdf", height = 6, width = 10)
par(mfrow = c(1,2))
plot(jitter(df$inf.prob, factor = 1000), df$incid, pch = 20, col = adjustcolor("black", alpha.f = 0.1,),
     xlab = "Parameter", ylab = "Cumulative Incidence", main = "Infection Probability")
plot(jitter(df$act.rate, factor = 2000), df$incid, pch = 20, col = adjustcolor("black", alpha.f = 0.1,),
     xlab = "Parameter", ylab = "Cumulative Incidence", main = "Contact Intensity")
dev.off()

fit <- lm(incid ~ dx.sympt.26 + dx.other.26 + I(inf.prob*100) + act.rate, data = df)
summary(fit)
coef(fit)
cbind(coef(fit), confint(fit))
