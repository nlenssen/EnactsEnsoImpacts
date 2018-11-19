# Regional ENSO Impacts Using ENACTS Data

## Super Quick Start Guide
0. Make sure the `Data/` directory is placed in the main`EnactsEnsoImpacts` directory
1. Open an R session and set the working directory to `EnactsEnsoImpacts`
2. Execute the test script by using the command `source('Scripts/run_TestCase.R')`



## Directory Structure and Hierarchy

### Scripts
Files in the scripts directory call 
### Namelists

### Code

### Figures

### Data


## Walk-through of `Scripts/run_TestCase.R` 
### Line 2: Source the Namelist
Load in the variables defined in the namelist using `source()`. The variables in the namelist are also sometimes referred to as **parameters** as they adjust the behavior of the entire analysis.

### Line 5: Clean the Data
Call the data processing script `Code/cleanDataCru.R` which:
* Loads in the monthly data from the raw netCDF file with name given by `cruFile` in the namelist
* Subsets the data in time according to `cruStartYear` and `cruEndYear` namelist variables
* Converts the monthly data to seasonal
* Neatly packages all data in the `observationList` variable and saves to disk. When making modifications to the `observationList`, make sure that (using `str()` to check dimensionality of objects in list)
	* The list names are `lon`, `lat`, `ppt`, `counts`, and `timeMap`
	* The number of rows in `timeMap` is the same as the number of time points in `ppt` and `counts`
	* The length of the `lon` and `lat` vectors are the same as the number of rows and columns in `ppt` and `counts`

Note, this line is only run if the data needs to be processed from the raw netCDF file. In general, we do not want to run this step as the code to take the seasonal mean if quite inefficient

### Line 8: Determine ENSO Years
Call the data processing script `Code/identifyENSO.R` which determines the top `topYears` El Nino and La Nina events for each season over the time period of interest. The value for `topYears` is set in the namelist. In general, this code will not need to be modified at all

### Line 11: Run the Modified Mason and Goddard 2001 Analysis 
Call the main analysis script `Code/impactsAnalysis.R` which runs a modified version of the ENSO impacts analysis outlined in [Mason and Goddard 2001](add-link)

### Line 14: