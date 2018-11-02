# Load in the required data
load(sprintf('Data/RawProcessed/%s',pptData))
load(sprintf('%s/ninaSeasonalInd.Rda',ddir))

# make sure we are working with the correct year range
timeMapFull   <- observationList$timeMap 
timeInds <- which(timeMapFull[,1] %in% startYear:endYear)
timeMap <- timeMapFull[timeInds,]

# Unpack the list to keep the legacy code
lon <- observationList$lon 
lat <- observationList$lat

pptSeasonal <- observationList$ppt[,,timeInds]
countsSeasonal <- observationList$counts[,,timeInds]


# objects that we are populating through the loops

# climatologies
climatology <- array(NA, dim=c(length(lon),length(lat),12))
terciles    <- array(NA, dim=c(length(lon),length(lat),12,2))
dryMask     <- array(NA, dim=c(length(lon),length(lat),12))

# sample sizes used to calculate everything
sampleSize <- array(NA, dim=c(length(lon),length(lat),12))
ensoYears  <- array(NA, dim=c(length(lon),length(lat),12,2))

# lon x lat x season x el/la x high/low anom
countsArray <- array(NA, dim=c(length(lon),length(lat),12,2,2))
sigCounts   <- array(NA, dim=c(length(lon),length(lat),12,2,2))
pValArray   <- array(NA, dim=c(length(lon),length(lat),12,2,2))

# loop through season
for(s in 1:12){

print(paste('Season #:',s))
cat('\n')

sInds <- which(timeMap[,2]==s)
ninaTemp <- ninaIndicator[,s]

# loop through lat lon
pb <- txtProgressBar(1,length(lon),style=3)
for(i in 1:length(lon)){
setTxtProgressBar(pb,i)
for(j in 1:length(lat)){

# extract the seasonal series for the location
pptTemp <- pptSeasonal[i,j,sInds]
stnTemp <- countsSeasonal[i,j,sInds]

if(all(is.na(pptTemp))) next

# build a mask for evey time the station count is too low
goodTimePoints <- which(stnTemp > countCutoff)
hasData        <- which(!is.na(pptTemp))

# use the good time points to build the climatology for this loc/season

goodDat <- pptTemp[goodTimePoints]

# If no good data, use the cru climatology to set clim/terciles
if(length(goodDat)>0){
	climatology[i,j,s] <- mean(goodDat)
	terciles[i,j,s,]   <- quantile(goodDat,probs=c(1/3,2/3))
} else{
	climatology[i,j,s] <- mean(pptTemp[hasData])
	terciles[i,j,s,]   <- quantile(pptTemp[hasData],probs=c(1/3,2/3))
}

dryMask[i,j,s] <- ifelse(terciles[i,j,s,1] < dryCutoff, 1, NA)

sampleSize[i,j,s] <- length(goodDat)

# get the series that determines which tercile the good dat falls in
tercSeries <- rep(0,length(goodDat))
tercSeries[goodDat<terciles[i,j,s,1]] <- -1
tercSeries[goodDat>terciles[i,j,s,2]] <- 1

# count the occurances of above and below percip for the el nino years
ninoInds <- which(ninaTemp[goodTimePoints]==1)
countsArray[i,j,s,1,1] <- sum(tercSeries[ninoInds]==1)
countsArray[i,j,s,1,2] <- sum(tercSeries[ninoInds]==-1)

ensoYears[i,j,s,1]    <- length(ninoInds)

# count the occurances of above and below percip for the la nina years
ninaInds <- which(ninaTemp[goodTimePoints]==-1)
countsArray[i,j,s,2,1] <- sum(tercSeries[ninaInds]==1)
countsArray[i,j,s,2,2] <- sum(tercSeries[ninaInds]==-1)

ensoYears[i,j,s,2]    <- length(ninaInds)


# calculate statistical significance of results

# el/la x high/low anom
cutoffVals <- matrix(NA,2,2)
pvals      <- list()

# run the calculation for ABOVE NORMAL precipitaiton
whiteBalls1 <- sum(tercSeries==1)
blackBalls1 <- length(goodDat) - whiteBalls1

pvals[[1]] <- cumsum(dhyper(1:length(ninoInds),whiteBalls1,blackBalls1,length(ninoInds)))
suppressWarnings(cutoffVals[1,1] <- min(which(pvals[[1]]>alpha)))

pvals[[2]] <- cumsum(dhyper(1:length(ninaInds),whiteBalls1,blackBalls1,length(ninaInds)))
suppressWarnings(cutoffVals[2,1] <- min(which(pvals[[2]]>alpha)))

# run the calculation for BELOW NORMAL precipitaiton
whiteBalls2 <- sum(tercSeries==-1)
blackBalls2 <- length(goodDat) - whiteBalls2

pvals[[3]] <- cumsum(dhyper(1:length(ninoInds),whiteBalls2,blackBalls2,length(ninoInds)))
suppressWarnings(cutoffVals[1,2] <- min(which(pvals[[3]]>alpha)))

pvals[[4]] <- cumsum(dhyper(1:length(ninaInds),whiteBalls2,blackBalls2,length(ninaInds)))

suppressWarnings(cutoffVals[2,2] <- min(which(pvals[[4]]>alpha)))


for(el in 1:2){
	for(hl in 1:2){
		tempCounts <- ifelse(countsArray[i,j,s,el,hl]>=cutoffVals[el,hl],
			countsArray[i,j,s,el,hl],-1)
		sigCounts[i,j,s,el,hl] <- tempCounts
		if(tempCounts== -1 ){
			pValArray[i,j,s,el,hl] <- -1
		} else{
			tempPval <- pvals[[2*(hl-1) + el]]
			pValArray[i,j,s,el,hl] <- tempPval[tempCounts]
		}
		

	}
}


# close the three loops (season/lon/lat)
}}
cat('\n')
}


propArray <- array(NA, dim=dim(countsArray))
for(s in 1:12){
	for(el in 1:2){
		for(hl in 1:2){
			tempCounts <- sigCounts[,,s,el,hl]
			tempCounts[tempCounts==-1] <- NA

			propArray[,,s,el,hl] <- tempCounts/ensoYears[,,s,el]
		}
	}
}

resultsList <- list(lon=lon,lat=lat,timeMap=timeMap,
	climatology=climatology, terciles=terciles, sampleSize=sampleSize,
	dryMask= dryMask, ensoYears=ensoYears, countsArray=countsArray, 
	sigCounts=sigCounts, pValArray=pValArray,propArray=propArray)

save(resultsList, file=sprintf('%s/maskedAnalysisResults.Rda',ddir))


