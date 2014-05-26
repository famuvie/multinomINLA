### Fixed probabilities ###

# Simulate multinomial data
n <- 1e3
p <- c(.3, .6, .1)
obs <- sample(LETTERS[1:3], n, replace = TRUE, prob = p)
table(obs)

# multinomINLA with observations at individual level
res.inla <- multinomINLA(obs ~ 1,
                         data = data.frame(obs = factor(obs)))
summary(res.inla)
res.inla$summary.multinomial
plot(res.inla$marginals.multinomial[[1]], type = 'l', xlim = c(0,1))
lines(res.inla$marginals.multinomial[[2]])
lines(res.inla$marginals.multinomial[[3]])
abline(v = p, col = 'red')

# although it will understand counts as well
res.inla.counts <- multinomINLA(Freq ~ obs, data = dat2)


### Multinomial log-linear model ###
# i.e. probabilities depend linearly on some fixed effects
require(MASS)
# TODO: replicar example(multinom)