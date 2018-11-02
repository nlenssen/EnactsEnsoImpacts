# load in the processed enso series
load('Data/RawProcessed/ninaSeasonal.Rda')

# arrange in a matrix for more intuitive calculations
endPadding <- rep(NA,12 - length(ninaSeasonal$nina34) %% 12)
ninaMat <- matrix(c(ninaSeasonal$nina34,endPadding), ncol=12,byrow=TRUE)

# we do the calculation for each season (column)
ninaIndicator <- matrix(0,nrow=nrow(ninaMat),ncol=ncol(ninaMat))

ensoArray <- array(NA, dim=c(topYears,12,2))
yearArray <- array(NA, dim=c(topYears,12,2))

# make sure we are working with the correct year range
tYearTemp <- min(ninaSeasonal$timeMap[,1]):max(ninaSeasonal$timeMap[,1])
timeInds  <- which(tYearTemp %in% startYear:endYear)

for(i in 1:ncol(ninaMat)){
	# set the top nina years for each season to -1
	ninaInds <- which(ninaMat[timeInds,i] %in% sort(ninaMat[timeInds,i],decreasing=FALSE)[1:topYears])
	ninaIndicator[ninaInds,i] <- -1

	# set the top nino years for each season to 1
	ninoInds <- which(ninaMat[timeInds,i] %in% sort(ninaMat[timeInds,i],decreasing=TRUE)[1:topYears])
	ninaIndicator[ninoInds,i] <- 1

	# Now, make a readable table of the top years and vals
	tempMat <- cbind(tYearTemp[timeInds],ninaMat[timeInds,i])
	orderedMat <- tempMat[order(tempMat[,2]),]


	yearArray[,i,2] <- orderedMat[1:topYears,1]
	ensoArray[,i,2] <- orderedMat[1:topYears,2]

	yearArray[,i,1] <- orderedMat[rev((nrow(tempMat)-topYears+1):nrow(tempMat)),1]
	ensoArray[,i,1] <- orderedMat[rev((nrow(tempMat)-topYears+1):nrow(tempMat)),2]

}


save(ninaIndicator,ensoArray,yearArray,file=sprintf('%s/ninaSeasonalInd.Rda',ddir))