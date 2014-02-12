#' Bayesian multinomial models with INLA
#' 
#' he package provides the function multinomINLA() for fitting
#' multinomial models in a simple and straightforward way, using the same
#' syntax as, e.g. nnet::multinom().
#' 
#' Since INLA cannot handle multinomial likelihoods, we use the 
#' Multinomial-Poisson transformation to reparameterize the model and fit 
#' independent Poisson observations.
#' The summaries and marginals for the multinomial probabilities are given 
#' in the resulting list object under the names summary.multinomial and
#' marginals.multinomial respectively.
#' 
#' @name multinomINLA-package
#' @aliases multinomINLA-package multinomINLA
#' @docType package
NULL