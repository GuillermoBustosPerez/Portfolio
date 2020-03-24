''' 
A basic system for quering and storing data from SQL files into pandas dataframes

SQL data from 
https://www.kaggle.com/harsha547/ipldatabase
'''
#  Import basic needed packages 
import pandas as pd
from sqlalchemy import create_engine

# Set up engine and get relational database table names
engine = create_engine('sqlite:///Data/database.sqlite')

table_names = engine.table_names()
print(table_names)

# Basic quering of a relational database and store as a pandas dataframe
with engine.connect() as con :
  rqst = con.execute("SELECT * FROM Player")
  df_players = pd.DataFrame(rqst.fetchall())
  df_players.columns = rqst.keys()

# Inner join from two data databases and into a pandas dataframe
Players_Country = pd.read_sql_query(
  "SELECT * FROM Player INNER JOIN Country on Player.Country_Name = Country.Country_Id", engine)

#...and print first five rows
print(Players_Country.head())


# Inner join of dataframes Players and Country using Pandas
players_countries = pd.merge(df_players, df_country,
left_on = 'Country_Name', right_on = 'Country_Id')

print(players_countries.head())
