#### Load data and make it into a ts ####
load("Data/Monthly sales.RData")
library(tidyverse); library(forecast); library(fpp2)

M_Sales <- ts(M_Sales, 
              start = c(2013, 2),
              frequency = 12)
