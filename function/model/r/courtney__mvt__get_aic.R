args <- commandArgs(trailingOnly = TRUE)

tmp_path <- args[1]
setwd( tmp_path )

rewards <- data.matrix( read.csv('tmp__rewards.csv', header=FALSE) )
response <- data.matrix( read.csv('tmp__response.csv', header=FALSE) )
n <- data.matrix( read.csv('tmp__n.csv', header=FALSE) )
n2 <- data.matrix( read.csv('tmp__n2.csv', header=FALSE) ) 

rewards <- rewards / max(rewards)
n <- n / 1e3
n2 <- n^2
combined <- data.matrix( data.frame(rewards, n, n2) )

anon <- response ~ rewards + n + n2

#fitted <- glm.fit(combined, response, intercept=FALSE)
fitted <- glm( anon, family=gaussian )

#time <- seq(0, length(prob_matrix2)-1)
#data <- data.frame(time, prob_matrix2, binned)

#anon <- prob_matrix2 ~ binned / (1+k*travel_time)
#w <- nls(anon, start=list(k=.01), data=data,trace=FALSE, control=list(maxiter=500))

aic = fitted$aic
#	print aic
print(aic)
#	print 'k'
print( summary(w)$coefficients[1] )
#	print the log likelihood
print( data.matrix(summary(logLik(w))[1])[1] )

