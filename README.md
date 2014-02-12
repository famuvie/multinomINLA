multinomINLA
======

### Bayesian multinomial models with INLA

#### Description
The package provides the function multinomINLA() for fitting multinomial
models in a simple and straightforward way, using the same syntax as e.g. 
`nnet::multinom()`.

Since INLA cannot handle multinomial likelihoods, we use the 
Multinomial-Poisson transformation to reparameterize the model and fit 
independent Poisson observations.
The summaries and marginals for the multinomial probabilities are given 
in the resulting list object under the names summary.multinomial and
marginals.multinomial respectively.

Moreover, the function admits individual observations rather than category counts.
This allows using the same syntax as other packages, and more flexible modelling.

#### TODO
 - For the moment `multinomINLA` fits multinomial probabilities for one single 
 population. In the future, it will allow group-wise multinomial probabilities.

#### Citing
- If you use this package please cite it
- `citation('multinomINLA')`