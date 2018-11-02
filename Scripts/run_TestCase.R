# Load in the run parameters from the namelist
source(sprintf('Namelists/namelist_TestCase.Rnl'))

# Process the raw data if requested
if(cleaningData) source('Code/cleanDataCru.R')

# Detect enso years
source('Code/identifyEnso.R')

# Run the bulk of the analysis
source('Code/impactsAnalysis.R')

# Run the area calculation
source('Code/affectedAreaCalculation.R')

# Make plots if requested
if(plotting) source('Code/plotImpactsAnalysis.R')