#anon <- y ~ exp( (.6/(1+k*1) - x/(1+k*1)) / sigma ) / ( 1 + exp( (.6/(1+k*1) - x/(1+k*1)) / sigma ) )

#anon <- y ~ exp( (1-x)/sigma ) / ( 1 + exp( (1-x)/sigma ) )
#anon <- y ~ 1/(1+exp(-(1-x)/sigma))
#anon <- y ~ 1/(1+exp(-(1-prob_matrix)/sigma))


##
setwd('/Users/Nick/Desktop/temp_data')
#prob <- read.csv('test__mle.csv')
binned <- data.matrix( read.csv('test__binned.csv', header=FALSE) )
binned = binned / max(binned)

prob <- read.csv('test__p_leave.csv')
prob_matrix2 <- data.matrix(prob)
prob_matrix2 <- c(0, prob_matrix2)

time <- seq(0, length(prob_matrix2)-1)
data <- data.frame(time, prob_matrix2, binned)

travel_time <- 1

#anon <- prob_matrix2 ~ 1/exp( -(binned[1]/(1+k*travel_time) - binned/(1+k*.2))/sigma )
#anon <- prob_matrix2 ~ 1/(1+exp(-(1-time)/sigma))

anon <- prob_matrix2 ~ binned / (1+k*travel_time)

#w <- nls(anon, start=list(sigma=.01,k=.01), data=data,trace=TRUE, control=list(maxiter=500))
w <- nls(anon, start=list(k=.01), data=data,trace=TRUE, control=list(maxiter=500))
#w <- nls(anon, start=list(sigma=1), data=data,trace=TRUE)

##


