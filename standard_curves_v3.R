##################
## Standard Curves
## Jason M. Klemm
## 16 Sep 2025
##################

## The purpose of this script is to generate standard curves from the cleaned data

##############################
## Libraries and functions
library(drc)
library(ggplot2)
source("/Users/jasonklemm/Desktop/targeted_aq_r/aq_functions.R")
##############################

## cleans out global env
rm(list=ls()) 

## load in cleaned standards data
load("/Users/jasonklemm/Desktop/targeted_aq_r/Data/cleaned_data_standards.RDS")

## create log logistic 4PL model for standard curve generation
dose_response <- drc::drm(percent_inhibition~log_conc, data = newdata_standards, fct = LL.4(names = c("Slope", "Lower Limit", "Upper Limit", "ED50")), logDose = 10, type = "continuous")

## create vector and data frame of sequenced numbers to serve as predictions and x-values for band generation in ggplot
x_grid <- seq(min(newdata_standards$log_conc), max(newdata_standards$log_conc), length.out = 200)
nd <- data.frame(log_conc = x_grid)

## predict fitted means and SEs 
## type = "response" keeps the original response scale (percent inhibition)
pred <- predict(dose_response, newdata = nd, se.fit = TRUE, type = "response")

## get variables to compute 95% CI bands 
alpha <- 0.05
df_resid <- dose_response$df.residual
tcrit <- qt(1 - alpha/2, df_resid)

fit <- as.numeric(pred[, 1])
se <- as.numeric(pred[, 2])
ymin <- fit - tcrit * se
ymax <- fit + tcrit * se

## create data frame for geom_ribbon to draw 95% CI bands on LL.4PL plot
ribbon_df <- data.frame(
  x = x_grid,         
  y = fit,            
  ymin = ymin,
  ymax = ymax
)

## calculate the limits of quantitation (LOQ)
loq_function <- function(upper, lower, k=4.6805){
  
  upper_bound <- ((lower-upper)/(1+k))+upper
  lower_bound <- ((lower-upper)/(1+(1/k)))+upper
  
  return(c(upper_bound=upper_bound, lower_bound=lower_bound))
  
}

## assign values of loq to a vector
loq_bounds <- loq_function(dose_response$coefficients[3], dose_response$coefficients[2])

## plot the standard curve 
p <- ggplot() +
  ## points (raw data)
  geom_point(
    data = newdata_standards,
    aes(x = log_conc, y = percent_inhibition, color = "Observed"),
    size = 2
  ) +
  ## ribbon (95% CI/band)
  geom_ribbon(
    data = ribbon_df,
    aes(x = x, ymin = ymin, ymax = ymax, fill = "95% Confidence Band"),
    alpha = 0.2,
    inherit.aes = FALSE
  ) +
  ## fitted line from LL.4PL
  geom_line(
    data = ribbon_df,
    aes(x = x, y = y, color = "LL.4PL Fit"),
    linewidth = 1,
    inherit.aes = FALSE
  ) +
  ## horizontal LOQ bounds
  geom_hline(aes(yintercept = loq_bounds[2], color = "LOQ Lower"), linetype = "dashed", linewidth = 1) +
  geom_hline(aes(yintercept = loq_bounds[1], color = "LOQ Upper"), linetype = "dashed", linewidth = 1) +
  labs(
    title = "Targeted AQ 2025 DF40 Plate 1",
    x = expression(Log[10]~"of Standard Concentration"),
    y = "Percent Inhibition",
    color = "Elements",
    fill  = "95% CI Band",
  ) +
  theme_bw(base_size = 15) +
  theme(plot.title = element_text(hjust = 0.5)) +
  ## defines the legend appearance according to the aes we set
  scale_color_manual(
    values = c(
      "Observed" = "black",
      "LL.4PL Fit" = "black",
      "LOQ Upper" = "red",
      "LOQ Lower" = "blue"),
    labels = c(
      "Observed" = "Observed",
      "LL.4PL Fit" = "LL.4PL Fit",
      "LOQ Upper" = paste0("LOQ Upper = ", round(loq_bounds[1], 2)),
      "LOQ Lower" = paste0("LOQ Lower = ", round(loq_bounds[2], 2))
    )
  ) +
    scale_fill_manual(values = c("95% Confidence Band" = "darkgray")) +
    guides(linetype = "none",  color = guide_legend(order = 1),
      fill  = guide_legend(order = 2)) + theme(legend.position = "right", 
      legend.title = element_text(size = 12), legend.text = element_text(size = 10))

## view plot of standard curve
p 

## save the plot
ggsave("/Users/jasonklemm/Desktop/targeted_aq_r/Data/standard_curve.pdf", plot = p, width = 10, height = 7, dpi = 300)




