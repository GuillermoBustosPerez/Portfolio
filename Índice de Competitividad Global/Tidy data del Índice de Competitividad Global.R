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

# Boolean vector to check if all rows from 6th column to the end are Na's
# Vector booleano indcando si faltan todos los datos de la fila desde la columna 6 hasta el final
ind <- apply(Comp_2019[, 6:ncol(Comp_2019)], 1, function(x) all(is.na(x)))

# Filter using the boolean vector
# Filtrar los datos usando el vector booleano
Comp_2019 <- Comp_2019[ !ind, ]

# Drop duplicated rows from "Series name", but keeping the ones where Attribute = SCORE
# Retirar duplicados de "Series Name", conservando prioritariamente aquellos en los que Attribute = SCORE
Comp_2019 <- 
  setDT(Comp_2019)[, .SD[which.min(factor(Attribute, levels = c("SCORE","VALUE")))], 
                              by=.(`Series name`)]

#### Second rownd of filtering ####
# Values for each country into a new dataframe and transform into numeric
# Indicadores de cada país en un data frame nuevo y hacerlo numérico
Countries <- Comp_2019 %>% select(c(Angola: last_col()))
Countries[] <- lapply(Countries , function(x) as.numeric(as.character(x)))

# Reorder columns
# Reordenar columnas
Comp_2019 <- Comp_2019 %>%  select(c("Edition", "Series type", 
               "Series name", "Series units", "Attribute"))

# Join Data frame of cilumns and countries
# Unir indicadores numéricos de cada país con el orden apropiado de columnas
Comp_2019 <- cbind(Comp_2019, Countries)

# New data frame with regional averages and remove from the one of countries                      
# Nuevo data frame con los promedios de cada región y liminar los promedios regionales del data frame con los países 
Averages <- Comp_2019 %>% select(`Series name`, `Series type`,
                            `Europe and North America`:`Sample average`) 

Comp_2019 <- Comp_2019 %>% 
  select(-c(`Europe and North America`:`Sample average`))
        
# Filter non desirable cases 
# Filtrar casos no apropiados (ruido)
Comp_2019 <- Comp_2019 %>% filter(`Series type` != "Label (does not enter calculation)" &
                                    `Series type` != "Index")
                      
##### Last round of filtering ####

# Create column Pillar as a copy of `Series Name`
# Crear columna Pillar como copia de Series Name
Comp_2019$Pillar <- Comp_2019$`Series name`

# Assign Na if it doesent contain "pillar"
# Asignar Na si no contiene "pillar"
Comp_2019$Pillar <- ifelse(grepl("pillar" , Comp_2019$Pillar), Comp_2019$Pillar, NA)

# Foreward autocomplete
# Autocompletado hacia adelante
library(zoo)
Comp_2019$Pillar <- na.locf(Comp_2019$Pillar)

# Reorder columns
# Reordenar columnas
Comp_2019 <- Comp_2019 %>% select("Edition", "Series type", 
            "Series name", "Pillar", "Series units", Angola: last_col())
