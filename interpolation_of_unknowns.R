##################
## Standard Curves
## Jason M. Klemm
## 16 Sep 2025
##################

## The purpose of this script is to generate standard curves from the cleaned data

## cleans out global env
rm(list=ls()) 

##############################
## Libraries and functions
library(drc)
source("/Users/jasonklemm/Desktop/targeted_aq_r/aq_functions.R")
##############################

## load in cleaned standards and unknowns data
load("/Users/jasonklemm/Desktop/targeted_aq_r/Data/cleaned_data_standards.RDS")
load("/Users/jasonklemm/Desktop/targeted_aq_r/Data/cleaned_data_unknowns.RDS")

## create log logistic 4PL model for interpolation
dose_response <- drc::drm(percent_inhibition~log_conc, data = newdata_standards, fct = LL.4(names = c("Slope", "Lower Limit", "Upper Limit", "ED50")), logDose = 10, type = "continuous")

## assign values of loq to a vector
loq_bounds <- loq_function(dose_response$coefficients[3], dose_response$coefficients[2])

## get values of loq in U
ed_loq_bounds <- ED(dose_response, loq_bounds, type = "absolute")

## interpolate the unknowns using the 4PL model
interpolated_unknowns <- ED(dose_response, newdata_unknowns$percent_inhibition, type = "absolute")

## define the dilution factor of the samples interpolated
df <- 40

## get final estimations for antibody quantity in serum
newdata_unknowns$Estimates <- interpolated_unknowns[, 1] * df

## calculate the upper and lower loq in U based on df
greater_loq <- newdata_unknowns$Estimates >= (ed_loq_bounds[1,1]*df) 
lesser_loq <- newdata_unknowns$Estimates >= (ed_loq_bounds[1,2]*df) 

## assign labels to samples
newdata_unknowns$LOQ[greater_loq] <- paste0("Greater than upper loq: ", (round(ed_loq_bounds[1,1]*df, 1)), " U/mL")
newdata_unknowns$LOQ[!greater_loq] <- "Within LOQ"

## save the final data
write.csv(newdata_unknowns, file = "/Users/jasonklemm/Desktop/targeted_aq_r/Data/cleaned_data_unknowns.csv", row.names = TRUE)
