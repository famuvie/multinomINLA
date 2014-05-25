
###
# I can do the same with the single observations!
# I need to augment the dataset with one additional observation per group
# And use a convenient offset
# TODO: make it work with additional covariates and models

#' Ordered and unordered multinomial Regression
#' 
#' @references Andrew Gelman and Jennifer Hill \emph{Data Analysis Using Regression and Multilevel/Hierarchical Models} Cambridge University Press (2006)
multinomINLA <- function(formula, data, ...) {
  mf <- model.frame(formula, data)
  mt <- attr(mf, 'terms')
  
  # Check whether the response are *counts* of observations per category
  # or an indicator of category at the individual level
  method <- ifelse(is.numeric(mf[[attr(mt, 'response')]]), 'counts', 'individual')

  if(method == 'counts') {
    # introduce new parameters for each group
    dat <- cbind(data, phi = 1)
    
    ## To be implemented ...
    stop('Working with counts is not implemented yet...')
    
  } else {
    # Augment the data
    n = nrow(data)
    response.levels = levels(mf[[attr(mt, 'response')]])
    offsets <- n/(as.numeric(table(mf[[attr(mt, 'response')]])) + 1)
    
    dat <- data.frame(y.fake = c(rep(1:0, c(n, length(response.levels)))),
                      cat = c(as.numeric(mf[[attr(mt, 'response')]]), 1:length(response.levels)),
                      phi = 1)
    
    # Estimation stack
    stk.e <- inla.stack(tag = 'est',
                        data = list(y.fake = dat$y.fake,
                                    offs = offsets[dat$cat]),
                        A    = 1,
                        effects = list(dat[, -1]))
    
    # Prediction stack
    stk.p <- inla.stack(tag = 'pred',
                        data = list(y.fake = 1,
                                    offs = offsets),
                        A    = 1,
                        effects = list(data.frame(cat = 1:length(response.levels),
                                                  phi = 1)))
    stk.full <- inla.stack(stk.e, stk.p)
    # Inference
    # We treat the parameters as fixed effects with small prior precision
    prior.prec = list(prec = list(initial = log(1e-4), fixed=TRUE))
    res <- inla(y.fake ~ f(cat, model = 'iid', hyper = prior.prec) +
                  f(phi, model = 'iid', hyper = prior.prec) - 1,
                family = 'poisson',
                data = inla.stack.data(stk.full),
                E = inla.stack.data(stk.full)$offs,
                control.predictor = list(compute = TRUE,
                                         A = inla.stack.A(stk.full)))
    
    # Posterior densities of categories
    pred.idx <- inla.stack.index(stk.full, 'pred')$data
    res$marginals.multinomial <- res$marginals.fitted.values[pred.idx]
    names(res$marginals.multinomial) <- response.levels
    
    # osterior summaries of categories
    res$summary.multinomial <- res$summary.fitted.values[pred.idx, ]
    rownames(res$summary.multinomial) <- response.levels
  }
  return(res)
}
