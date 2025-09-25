##################
## Data Cleaning
## Jason M. Klemm
## 16 Sep 2025
##################

## The purpose of this script is to clean the raw data coming off the plate reader for antibody quantitation

##############################
## Libraries and functions
source("/Users/jasonklemm/Desktop/targeted_aq_r/aq_functions.R")
##############################

## cleans out global env
rm(list=ls()) 

## load in your text file -- use unique directory for where you have yours saved
data <- read.delim("/Users/jasonklemm/Downloads/JMK/ReturnoftheTiter/WT/Targeted_AQ_2025_DF40_Plate1.txt")

## vector used to rename columns
rename_vec <- c("Measurement_Results", "Group", "Type", "Sample", "Wavelength(nm)", "Abs", "Time(s)") 

## rename column names for clarity
for (i in 1:length(rename_vec)){ 
  
  colnames(data)[i] <- rename_vec[i]
  
} ## end for

## create new data frame containing only the columns used in analysis
newdata <- data.frame(Type = data$Type, Sample = data$Sample, Abs = as.numeric(data$Abs)) 

## remove all empty rows 
newdata <- newdata[c(-1:-9,-106:-112), ]

## make subsets of each type within the new data frame
newdata_standards <- subset.data.frame(newdata, newdata$Type == "Standard")

newdata_controls <- subset.data.frame(newdata, newdata$Type == "Control")

newdata_unknowns <- subset.data.frame(newdata, newdata$Type == "Unknown")

############################ Standards

## creates and orders new column of average abs values for each standard
newdata_standards <- aggregate(Abs ~ Sample, data = newdata_standards, FUN = mean)

newdata_standards <- newdata_standards[order(as.numeric(newdata_standards$Sample), decreasing = TRUE ), ]

colnames(newdata_standards)[2] <- "abs_standard_means"

newdata_standards$log_conc <- log(as.numeric(newdata_standards$Sample), base = 10) 

############################ Controls

## creates new column of average abs values for each control
newdata_controls <- aggregate(Abs ~ Sample, data = newdata_controls, FUN = mean)

colnames(newdata_controls)[2] <- "abs_control_means"

############################ Unknowns

## creates new data frame containing average abs values for each unknown
newdata_unknowns <- aggregate(Abs ~ Sample, data = newdata_unknowns, FUN = mean)

colnames(newdata_unknowns)[2] <- "abs_unknown_means"

############################ Percent inhibition standards

## calculate percent inhibition for standards
newdata_standards$percent_inhibition <- NULL
for (i in 1:length(newdata_standards$abs_standard_means)){ 
  
  newdata_standards$percent_inhibition[i] <- percent_inhibition_function(newdata_controls[2,2], newdata_standards[i,2])
  
} ## end for

############################ Percent inhibition controls

## calculate percent inhibition for controls
newdata_controls$percent_inhibition <- NULL
for (i in 1:length(newdata_controls$abs_control_means)){ 
  
  newdata_controls$percent_inhibition[i] <- percent_inhibition_function(newdata_controls[2,2], newdata_controls[i,2])
  
} ## end for

############################ Percent inhibition unknowns

## calculate percent inhibition for unknowns
newdata_unknowns$percent_inhibition <- NULL
for (i in 1:length(newdata_unknowns$abs_unknown_means)){ 
  
  newdata_unknowns$percent_inhibition[i] <- percent_inhibition_function(newdata_controls[2,2], newdata_unknowns[i,2])
  
} ## end for

############################ save workspace data and prepare to use next analysis script

## choose own directory and name for the file
save.image(file = "/Users/jasonklemm/Desktop/targeted_aq_r/Data/cleaned_data.RDS")
save(newdata_standards, file = "/Users/jasonklemm/Desktop/targeted_aq_r/Data/cleaned_data_standards.RDS" )
save(newdata_unknowns, file = "/Users/jasonklemm/Desktop/targeted_aq_r/Data/cleaned_data_unknowns.RDS" )

