# element-multiply each field in an array by a matrix (INEFFICIENT)
arrMult <- function(arr,mat){
	outArr <- array(NA, dim=dim(arr))
	for(i in 1:dim(arr)[3]){
		outArr[,,i] <- arr[,,i] * mat
	}
	return(outArr)
}

# Function to generate a nice diverging colorbar
redBlue <- function(n=256){
	require(fields)
	require(RColorBrewer)
	rev(designer.colors(n, brewer.pal(11,'RdBu')))
}

# averages a monthly time series into a seasonal time series
seasonalAverage12 <- function(ts,tYear){

	nMonth <- length(ts)
	nYear <- length(tYear)

	outMat <- matrix(NA, nrow=length(tYear)-1, ncol=12)
	
	rownames(outMat) <- tYear[2:nYear]
	colnames(outMat) <- c('DJF', 'JFM', 'FMA', 
						  'MAM', 'AMJ', 'MJJ',
						  'JJA', 'JAS', 'ASO',
						  'SON', 'OND', 'NDJ')

	for(i in 2:nYear){
		tsInd <- 1 + 12*(i-1)

		for(j in 1:12){
			seasonInds <- ( (j-2) : j)
			outMat[i-1,j] <- mean(ts[tsInd+seasonInds])
		}
	}



	return(outMat)
}


# applies a function to convert a monthly field into a seasonal field
seasonalField12 <- function(arr,tYear,FUN){
	nlon <- dim(arr)[1]
	nlat <- dim(arr)[2]

	outTime <- (length(tYear)-1) * 12 # not sure about this dimensionality rn

	outArray <- array(NA, dim = c(nlon,nlat,outTime))

	nYear <- length(tYear) - 1

	pb   <- txtProgressBar(2, nYear, style=3)

	for(i in 2:nYear){
		setTxtProgressBar(pb, i)

		tsInd <- 1 + 12*(i-1)

		for(j in 1:12){
			seasonInds <- ( (j-2) : j)
			if(max(tsInd+seasonInds) <= dim(arr)[3]){
				outArray[,,((i-2)*12 + j)] <- apply(arr[,,tsInd+seasonInds],c(1,2),FUN)
			}
		}
	}

	return(outArray)
}

