# Targeted_WTD_AQ_4PL

These scripts and functions were made as part of a small project involved in quantitating the antibodies present in White-tailed deer serum. Be mindful that the scripts here will need to be modified if the raw data files coming off the your particular instrument are in a different format. The scripts are meant to be completed in order starting with data cleaning which should always occur first, then standard curve generation followed by interpolation of the unknown samples.

## Data cleaning

This script is used for reading in and cleaning raw data txt files that come off of the plate reader.  Additionally, ensure that the aq_function.R file is sourced into your environment so that you can calculate percent inhibition of your samples.

The sequence of tasks that occur here are the following:

1. The raw data is wrangled into a new format easier for calculations and analysis
   1. Separated by sample group
2. Replicates for each standard, unknown, and control based on sample group are averaged.
3. Percent inhibition for each standard, unknown, and control based on sample group is calculated.
4. Resulting data .RDS files and a the workspace image are saved for further analysis.

## Standard Curve Generation

This script is used for generating standard curves for each plate that was ran and cleaned through the last step. Ensure that ensure that the aq_function.R file is sourced into your environment so that you can calculate limits of quantitation.

The sequence of tasks that occur here are the following:

1. A 4PL model is made based on the standard curve data.
2. 95% confidence interval bands and limits of quantitation bounds are calculated.
3. The standard curve is plotted and saved using ggplot.

## Interpolation of Unknowns

This script is used to interpolate the antibody quantity in units (U) present in each unknown. Ensure that ensure that the aq_function.R file is sourced into your environment so that you can calculate limits of quantitation. The dilution factor used for each unknown/set will also be needed.

The sequence of tasks that occur here are the following:

1. A 4PL model is made based on the standard curve data.
2. The limits of quantitation bounds are calculated.
3. The unknowns are interpolated and multiplied by their respective dilution factor.
4. The unknown is then assigned a label based on whether it is in within limits of quantitation or outside with a limit estimation.
5. The final data is then saved as a CSV.

**NOTE:** These scripts are currently only running one specified data file at a time. 
