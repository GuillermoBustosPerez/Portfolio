#### Load required packages ####
library(tidyverse)
library(readxl)
library(ggsci)
library(data.table)

#### Load in data set ####  
# Skip the first three rows
# n/a are actually not available data
Comp_2019 <- read_excel("Data/WEF_GCI_4.0_2019_Dataset.xlsx", 
                   sheet = "Data", skip = 3, 
                   na = c("n/a", "N/Appl.", "not assessed", "Not assessed"))

#### First round of diltering ####
# Filter to obtain 2019, attributes of interes and remove unnecesary columns
# Filtrar para obtener el año 2019, los datos de interés y librarse de columnas redundantes/de no interés
Comp_2019 <- Comp_2019 %>% filter(
  Edition == 2019 & 
    Attribute == "SCORE" | Attribute == "VALUE") %>% 
  select(-c("Index", "Series Global ID", "Freeze date",
            "Series code (if applicable)", "Series order"
            )) 


