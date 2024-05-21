
# Load packages -----------------------------------------------------------

library(tidyverse)
library(janitor)
library(readxl)
library(fs)

# Import data -------------------------------------------------------------

dir_create("data-raw")
dir_create("data")
dir_create("data-viz")

# We are going to explore some data from the world bank, especially data from the world bank development indicators

clean_fuels_cooking_raw <- read_csv("data-raw/access-clean-fuels-cooking.csv") |> 
  clean_names()

gdp_ppp_capita <- read_csv("data-raw/gdp-ppp-capita.csv") |> 
  clean_names()

clean_fuel_cooking_by_year <- clean_fuels_cooking_raw |> 
  select(country_name, country_code, x2000_yr2000:x2019_yr2019) |> 
  pivot_longer(cols = "x2000_yr2000":"x2019_yr2019",
               names_to = "year",
               values_to = "acfc") |> # % percentage of population with access clean fuel for cooking
  mutate(year = str_remove_all(year, pattern = "x\\d+_yr")) |> 
  mutate(year = parse_number(year)) |> 
  mutate(acfc = parse_number(acfc)) |> 
  mutate(id = row_number())

gdp_ppp_capita_by_year <- gdp_ppp_capita |> 
  select(country_name, country_code, x2000_yr2000:x2019_yr2019) |> 
  pivot_longer(cols = "x2000_yr2000":"x2019_yr2019",
               names_to = "year",
               values_to = "gdp") |> # gdp
  mutate(year = str_remove_all(year, pattern = "x\\d+_yr")) |> 
  mutate(year = parse_number(year)) |> 
  mutate(gdp = parse_number(gdp))|> 
  mutate(id = row_number())
  

gdp_clean_fuels <- left_join(gdp_ppp_capita_by_year,
          clean_fuel_cooking_by_year,
          join_by(id, country_name, country_code, year),
          keep = FALSE) 

gdp_clean_fuels_by_year <- na.omit(gdp_clean_fuels)

access_clean_fuel_gdp <- relocate(gdp_clean_fuels_by_year, id, .before = country_name)

write_rds(access_clean_fuel_gdp,
          file = "data/access_clean_fuel_gdp.rds")



