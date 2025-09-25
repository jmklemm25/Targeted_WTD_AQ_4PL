##################
## AQ functions
## Jason M. Klemm
## 16 Sep 2025
##################

############################ Percent inhibition function

percent_inhibition_function<- function(neg_control_avg_abs, sample_avg_abs){

  percent_inhibition <- ((1 - (sample_avg_abs/neg_control_avg_abs))*100)

  return(percent_inhibition)

} ## end function

############################ limits of quantitation function

loq_function <- function(upper, lower, k=4.6805){

  upper_bound <- ((lower-upper)/(1+k))+upper
  lower_bound <- ((lower-upper)/(1+(1/k)))+upper

  return(c(upper_bound=upper_bound, lower_bound=lower_bound))

}
