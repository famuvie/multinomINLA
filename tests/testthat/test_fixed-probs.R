#### Constant probabilities ####
context('Constant probabilities')

# Simulate multinomial data
n <- 1e3
p <- c(.3, .6, .1)
obs <- sample(LETTERS[1:3], n, replace = TRUE, prob = p)
# table(obs)

# Classical multinomial fit
require(nnet)
res.mn <- multinom(factor(obs) ~ 1)
# summary(res.mn)
point.nnet <- as.vector(predict(res.mn, 1, type = 'probs'))


# Should I compare multinomINLA with classical results,
# with manually worked-out examples in INLA, or with both?

# INLA can not handle multinomial likelihoods.
# Rather, it is necessary to use the following trick

# Multinomial-Poisson transformation
# y_i | p_i are assumed *independent* Poisson random variables
# with mean mu_i = n p_i.
# The multinomial model requires p_1 + p_2 + p_3 = 1
# Thus, we reparamtereize as follows:
# p_i = exp(a_i) / sum_i(exp(a_i)), a_i \in R
# And log(mu_i) = log(n) + a_i - A,
# where A = log(sum_i exp(a_i))

# Count data
# dat2 <- data.frame(table(obs))
# # no need to establish one reference?
# # dat2$obs[1] <- NA    # reference
# # Additional parameter to go from Multinomial to Poisson
# dat2$phi <- 1
# 
# # Not necessary in principle, but Havard uses it in the alli example.
# # This makes a random iid effect to work as a fixed effect with sufficiently
# # small precision
# prior.prec = list(prec = list(initial = log(1e-04), fixed=TRUE))
# res2 <- inla(Freq ~ f(obs, model = 'iid', hyper = prior.prec) + 
#                f(phi, model = 'iid', hyper = prior.prec) - 1,
#              family = 'poisson',
#              data = dat2,
#              E = n,
#              control.predictor = list(compute = TRUE))
# summary(res2)
# res2$summary.fitted.values
# plot(res2$marginals.fitted.values[[1]], type = 'l', xlim = c(0,1))
# lines(res2$marginals.fitted.values[[2]])
# lines(res2$marginals.fitted.values[[3]])
# abline(v = p, col = 'red')




# multinomINLA()
res.inla <- suppressMessages(multinomINLA(obs ~ 1, data = data.frame(obs = factor(obs))))
# summary(res.inla)
point.inla <- res.inla$summary.multinomial$mean
sd.inla <- res.inla$summary.multinomial$sd
# plot(res.inla$marginals.multinomial[[1]], type = 'l', xlim = c(0,1))
# lines(res.inla$marginals.multinomial[[2]])
# lines(res.inla$marginals.multinomial[[3]])
# abline(v = p, col = 'red')

# Point estimates
test_that('multinomINLA produces the same point estimates as nnet',{
  expect_equal(point.nnet, point.inla, tol = 1e-02)
})


# Credible intervals
test_that('SD are at least an order of magnitude below the estimates', {
  expect_true(all(sd.inla/point.inla < .1))
})


# Residual deviance/likelihood
# TODO