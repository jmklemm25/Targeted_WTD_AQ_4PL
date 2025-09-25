##################
## Standard Curves
## Jason M. Klemm
## 16 Sep 2025
##################

## The purpose of this script is to generate standard curves from the cleaned data

##############################
## Libraries and functions
library(drc)
source("/Users/jasonklemm/Desktop/targeted_aq_r/aq_functions.R")
##############################

## cleans out global env
rm(list=ls()) 

## load in cleaned standards and unknowns data
load("/Users/jasonklemm/Desktop/targeted_aq_r/Data/cleaned_data_standards.RDS")
load("/Users/jasonklemm/Desktop/targeted_aq_r/Data/cleaned_data_unknowns.RDS")

## create log logistic 4PL model for standard curve generation
dose_response <- drc::drm(percent_inhibition~log_conc, data = newdata_standards, fct = LL.4(names = c("Slope", "Lower Limit", "Upper Limit", "ED50")), logDose = 10, type = "continuous")

## assign values of loq to a vector
loq_bounds <- loq_function(dose_response$coefficients[3], dose_response$coefficients[2])

ed_loq_bounds <- ED(dose_response, loq_bounds, type = "absolute")

interpolated_unknowns <- ED(dose_response, newdata_unknowns$percent_inhibition, type = "absolute")

cat("Please input the diltuion factor used on this plate. If mixed please run script manually. ")
df <- scan("stdin", what = numeric(), n = 1)

newdata_unknowns$Estimates <- interpolated_unknowns[, 1] * df

greater_loq <- newdata_unknowns$Estimates >= (ed_loq_bounds[1,1]*df) 
lesser_loq <- newdata_unknowns$Estimates >= (ed_loq_bounds[1,2]*df) 

newdata_unknowns$LOQ[greater_loq] <- paste0("Greater than upper loq: ", (round(ed_loq_bounds[1,1]*df, 1)), " U/mL")
newdata_unknowns$LOQ[!greater_loq] <- "Within LOQ"

write.csv(newdata_unknowns, file = "/Users/jasonklemm/Desktop/targeted_aq_r/Data/cleaned_data_unknowns.csv", row.names = TRUE)
