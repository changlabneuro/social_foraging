args <- commandArgs(trailingOnly = TRUE)

tmp_path <- args[1]
travel_time <- as.numeric( args[2] )
#	account for saccade latency
travel_time <- travel_time + .2
setwd( tmp_path )

binned <- data.matrix( read.csv('tmp__binned.csv', header=FALSE) )
prob_matrix2 <- data.matrix( read.csv('tmp__p_leave_pdf.csv', header=FALSE))

#prob <- read.csv('tmp__p_leave_pdf.csv')
#prob_matrix2 <- data.matrix(prob)
#prob_matrix2 <- c(0, prob_matrix2)

time <- seq(0, length(prob_matrix2)-1)
data <- data.frame(time, prob_matrix2, binned)

anon <- prob_matrix2 ~ binned / (1+k*travel_time)
w <- nls(anon, start=list(k=.01), data=data,trace=FALSE, control=list(maxiter=500))

aic = AIC(w)
#	print aic
print(aic)
#	print 'k'
print( summary(w)$coefficients[1] )
#	print the log likelihood
print( data.matrix(summary(logLik(w))[1])[1] )
#	get + print the RMSE
resids <- summary(w)$residuals
rmse <- sqrt( sum((resids^2 / length(resids))) )
print( rmse )

