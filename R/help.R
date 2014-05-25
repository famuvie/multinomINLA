#' Bayesian multinomial models with INLA
#' 
#' The package provides the function \code{multinomINLA} for fitting multinomial
#' models in a simple and straightforward way, using the same syntax as, e.g. 
#' \code{nnet::multinom}.
#' 
#' Since INLA cannot handle multinomial likelihoods, we use the 
#' Multinomial-Poisson transformation to reparameterize the model and fit 
#' independent Poisson observations. The summaries and marginals for the 
#' multinomial probabilities are given in the resulting list object under the 
#' names summary.multinomial and marginals.multinomial respectively.
#' 
#' Furthermore, \code{multinomINLA} handle datasets in both \emph{sumarized} or 
#' \emph{individual} format. In the former the response variable contains the 
#' counts for each multinomial level, while in the latter the response variable 
#' is the actual level observed for each individual. This approach allows to
#' combine the multinomial likelihood with latent models at the individual
#' level, e.g. a spatial effect.
#' 
#' @name multinomINLA-package
#' @aliases multinomINLA-package multinomINLA
#' @docType package
NULL