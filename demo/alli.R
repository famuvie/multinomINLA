### Winbugs Alligator example, as resolved by the INLA team ###

define.constr <- function(reference.i, reference.k, reference.j, alli,
                          ni = I, nk = K, nj = J)
{
  ## This function define the corner point constaint
  ##reference.i = reference category for  food
  ##reference.k = reference category for lake
  ##reference.j = reference category for size
  
  ## DEFINE CONSTRAINT   
  xx=numeric(ni+nk)
  kk=1
  for(k in 1:nk) {
    xx[kk]=idx.map(reference.i, k, ni)
    alli$ik[alli$ik==xx[kk]] = NA
    kk=kk+1
  }
  for(i in 1:ni) {
    xx[kk]=idx.map(i, reference.k, ni)
    alli$ik[alli$ik==xx[kk]] = NA
    kk=kk+1
  }
  
  xx=numeric(nj+nk)
  kk=1
  for(k in 1:nk) {
    xx[kk]=idx.map(reference.j, k, nj)
    alli$jk[alli$jk==xx[kk]] = NA
    kk=kk+1
  }
  for(j in 1:nj) {
    xx[kk]=idx.map(j, reference.k, nj)
    alli$jk[alli$jk==xx[kk]] = NA
    kk=kk+1
  }
  
  alli$food[alli$food==reference.k]=NA
  return(alli)
}

idx.map = function(i,j,ni)
{
  ## this function goes from the two index [i,j] to one index
  return (i + (j-1)*ni)
}

## Model with corner point constrains as in WINBUGS

alli = read.table("data/alli-dataset.dat", header=TRUE)

I = ni = 4 # number of food categories
J = nj = 2 # number of size categories
K = nk = 5 # number of lake categories


## get the index for beta_ik
nn =dim(alli)[1]
ik = numeric(nn)
ik.names=character(nn)
for(ii in 1:nn) {
  ik[ii] = idx.map(alli$lake[ii], alli$food[ii], ni)
  ik.names[ii] = paste("[",alli$lake[ii],",", alli$food[ii],"]",sep="")
}
alli$ik = ik
alli$ik.names = as.factor(ik.names)

## get the index for gamma_jk
jk = numeric(nn)
jk.names = character(nn)
for(ii in 1:nn) {
  jk[ii] = idx.map(alli$size[ii], alli$food[ii], nj)
  jk.names[ii] = paste("[",alli$size[ii],",", alli$food[ii],"]",sep="")
  
}
alli$jk = jk
alli$jk.names = as.factor(jk.names)

## get the index for lambda_ij (this is the extra parameter needed to
## go from a multinomial to the Poisson)
ij = numeric(nn)
for(ii in 1:nn) {
  ij[ii] = idx.map(alli$lake[ii], alli$size[ii], ni)
}
alli$ij = ij


## define the contraint here we use conrner point contraints as in the
## WinBUGS manual, the reference categories are as in WinBUGS

alli1 = define.constr(1,1,1,alli)
prior.prec = list(prec = list(initial = log(0.00001), fixed=TRUE))

## write the formula

formula = counts ~ f(ij, model="iid", hyper = prior.prec ) +
  f(food,  constr = FALSE, hyper = prior.prec) +
  f(ik, constr=FALSE, hyper = prior.prec) +
  f(jk, constr=FALSE, hyper = prior.prec) -1

## run the model here i have used the lincomb option to compute the
## results using the sum-to-zero constraint so that you can compare
## these resuts with those in alli_model1.R (is exactly the same thing
## done in winbugs)

beta12 = inla.make.lincomb(ik = c(-0.25,-0.25,-0.25))
names(beta12)="beta12"
beta13 = inla.make.lincomb(ik = c(rep(NA,3), -0.25, -0.25, -0.25))
names(beta13)="beta13"
beta14 = inla.make.lincomb(ik = c(rep(NA,6), -0.25, -0.25, -0.25))
names(beta14)="beta14"
beta15 = inla.make.lincomb(ik = c(rep(NA,9), -0.25, -0.25, -0.25))
names(beta15)="beta15"
all.lc = c(beta12, beta13, beta14, beta15)

mod1 = inla(formula, data = alli1, family = "poisson",
            control.predictor = list(compute=TRUE),
            lincomb = all.lc)

