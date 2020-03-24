# Load required packages
library(RSQLite)
library(tidyverse)

# Connect to .sqlite and get table names
con <- dbConnect(SQLite(), "Data/database.sqlite")
as.data.frame(dbListTables(con))

#### Inner join of two data frames from SQLite file ####
# Get players table using a querry
players <- dbGetQuery(con, "SELECT * FROM Player")
# Read inn table
players <- dbReadTable(con, 'Player')

# Get Country table
country <- dbReadTable(con, 'Country')

# Make inner join
Player_Countries <- merge(players, country, by.x = "Country_Name", by.y = "Country_Id",
all = T)

#### Directly make the inner join ####
Inner_J <- dbGetQuery(con,
"SELECT * FROM Player INNER JOIN Country on
Player.Country_Name = Country.Country_Id"
)

#### Important in both options: disconnect from SQLite ####
dbDisconnect(con)
