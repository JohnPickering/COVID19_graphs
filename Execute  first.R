# COVID-19 Graphs for number of days needed to double

# 01 April: Updated to extract US data separately

library(tidyverse)
library(ggrepel)
library(lubridate)
library(rms)
library(splines)
library(readxl)
source("covid_fns.R")

# Load Data
# Source: Johns Hopkins University Center for Systems Science and Engineering (JHU CSSE)
confirmed_raw <- read_csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv")
deaths_raw <- read_csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv")
recovered_raw <- read_csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv")
confirmed_US <- read_csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv")
deaths_US <- read_csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv")

# Confirmed
confirmed_long_100 <- clean_jhd_to_long(confirmed_raw)
confirmed_long_100 <- confirmed_long_100 %>% 
  group_by(country) %>%
  mutate(ndays = 1:n()) %>%  
  ungroup() 
confirmed_long_100 <- confirmed_long_100 %>% 
  arrange(country, date) %>% 
  group_by(country) %>%
  mutate(change = ifelse(ndays == 1, 0, confirmed - lag(confirmed))) %>% 
  ungroup() %>% 
  filter(confirmed >= 100)  
  
confirmed_long_100 <- confirmed_long_100 %>% 
    group_by(country) %>%
    mutate(ndays = 1:n()) %>%  
    ungroup() 
confirmed_long_100 <- confirmed_long_100 %>% 
  mutate(change = ifelse(change < 5, NA, change)) %>% 
  mutate(dbl = (confirmed - change)/change) %>% 
  mutate(dbl = ifelse(is.infinite(dbl), NA, dbl)) 


unique_100 <- unique(confirmed_long_100$country)

countries <- data_frame(country = unique_100) %>% 
  mutate(location = case_when(
    country == "United Kingdom" | country == "Spain" | country == "Italy" | country == "Germany"  | country == "France" | country == "Norway" | 
      country == "Switzerland"  | country == "Austria"  | country == "Belgium"  | country == "Netherlands" | country == "Poland"  | 
      country == "Sweden" | country == "Portugal" | country == "Luxemburg" | country == "Ireland" |  country == "Finland" |  country == "Denmark" |
      country == "Greece" |  country == "Iceland" |  country == "Romania"  |  country == "Czechia"  |  country == "Russia"  |  country == "Serbia"  |
      country == "Croatia"   |  country == "Ukraine"   |  country == "Estonia"   |  country == "Slovenia" |  country == "Hungary" | country == "Moldova" | 
      country == "Bosnia and Herzegovina" | country == "Lithuania" ~ "Europe",
    country == "US" | country == "Mexico" | country == "Canada" | country == "Brazil"  |  country == "Chile" |  country == "Panama" | country == "Ecuador" |  
      country == "Peru" |  country == "Dominican Republic"  |  country == "Argentina" |  country == "Colombia" ~ "Americas",
    country == "New Zealand" | country == "Australia" ~ "Oceania",
    country == "China" | country == "Singapore" | country == "Korea, South" | country == "Japan" | country == "Hong Kong"  | country == "Malaysia"  | 
      country == "Indonesia"  | country == "Thailand"  | country == "Philippines"  |  country == "India" | country = "Bangladesh" ~ "Asia",
    country == "Iran" | country == "Saudi Arabia"  | country == "Israel" | country == "Turkey" | country ==  "United Arab Emirates"   |  
      country == "Iraq" | country = "Bahrain" | country == "Kazakhstan"  | country == "Azerbaijan" | country == "Uzbekistan"  | country == "Armenia" ~ "Gulf/Middle East",
    country == "South Africa" | country == "Egypt"  | country == "Morocco"  | country == "Tunesia"  | country == "Algeria" ~ "Africa",
    TRUE ~ "Other"
  ))

df_100 <- confirmed_long_100 %>% 
  left_join(countries, by = "country") %>% 
  mutate(ndays = ndays - 0.5) %>% # because when working out instantaneous slope is really the midpoint
  group_by(country) %>% 
  mutate(max_ndays = ifelse(ndays == max(ndays), max(ndays), NA)) %>% 
  ungroup()  


save(df_100, file = "CASES Greater 100.Rdata")

####### DEATHS #######


# deaths
deaths_long_10 <- clean_jhd_to_long(deaths_raw)
deaths_long_10 <- deaths_long_10 %>% 
  group_by(country) %>%
  mutate(ndays = 1:n()) %>%  
  ungroup() 
deaths_long_10 <- deaths_long_10 %>% 
  arrange(country, date) %>% 
  group_by(country) %>%
  mutate(change = ifelse(ndays == 1, 0, deaths - lag(deaths))) %>% 
  ungroup() %>% 
  filter(deaths >= 10)  

deaths_long_10 <- deaths_long_10 %>% 
  group_by(country) %>%
  mutate(ndays = 1:n()) %>%  
  ungroup() 
deaths_long_10 <- deaths_long_10 %>% 
  mutate(change = ifelse(change < 1, NA, change)) %>% 
  mutate(dbl = (deaths - change)/change) %>% 
  mutate(dbl = ifelse(is.infinite(dbl), NA, dbl)) 


unique_10 <- unique(deaths_long_10$country)



df_10 <- deaths_long_10 %>% 
  left_join(countries, by = "country") %>% 
  mutate(ndays = ndays - 0.5) %>% # because when working out instantaneous slope is really the midpoint
  group_by(country) %>% 
  mutate(max_ndays = ifelse(ndays == max(ndays), max(ndays), NA)) %>% 
  ungroup()  


save(df_10, file = "DEATHS Greater 10.Rdata")

##########  US
# Confirmed cases
confirmed_long_100US <- clean_jhd_to_long_US(confirmed_US)
confirmed_long_100US <- confirmed_long_100US %>% 
  group_by(state) %>%
  mutate(ndays = 1:n()) %>%  
  ungroup() 
confirmed_long_100US <- confirmed_long_100US %>% 
  arrange(state, date) %>% 
  group_by(state) %>%
  mutate(change = ifelse(ndays == 1, 0, confirmed - lag(confirmed))) %>% 
  ungroup() %>% 
  filter(confirmed >= 100)  

confirmed_long_100US <- confirmed_long_100US %>% 
  group_by(state) %>%
  mutate(ndays = 1:n()) %>%  
  ungroup() 
confirmed_long_100US <- confirmed_long_100US %>% 
  mutate(change = ifelse(change < 5, NA, change)) %>% 
  mutate(dbl = (confirmed - change)/change) %>% 
  mutate(dbl = ifelse(is.infinite(dbl), NA, dbl)) 

df_100US <- confirmed_long_100US %>% 
  #left_join(states, by = "state") %>% 
  mutate(ndays = ndays - 0.5) %>% # because when working out instantaneous slope is really the midpoint
  group_by(state) %>% 
  mutate(max_ndays = ifelse(ndays == max(ndays), max(ndays), NA)) %>% 
  ungroup()  

save(df_100US, file = "CASES US Greater 100.Rdata")


# deaths 
deaths_long_10US <- clean_jhd_to_long_US(deaths_US)
deaths_long_10US <- deaths_long_10US %>% 
  group_by(state) %>%
  mutate(ndays = 1:n()) %>%  
  ungroup() 
deaths_long_10US <- deaths_long_10US %>% 
  arrange(state, date) %>% 
  group_by(state) %>%
  mutate(change = ifelse(ndays == 1, 0, deaths - lag(deaths))) %>% 
  ungroup() %>% 
  filter(deaths >= 10)  

deaths_long_10US <- deaths_long_10US %>% 
  group_by(state) %>%
  mutate(ndays = 1:n()) %>%  
  ungroup() 
deaths_long_10US <- deaths_long_10US %>% 
  mutate(change = ifelse(change < 1, NA, change)) %>%   # Use <1 to avoid infinities
  mutate(dbl = (deaths - change)/change) %>% 
  mutate(dbl = ifelse(is.infinite(dbl), NA, dbl)) 

df_10US <- deaths_long_10US %>% 
  #left_join(states, by = "state") %>% 
  mutate(ndays = ndays - 0.5) %>% # because when working out instantaneous slope is really the midpoint
  group_by(state) %>% 
  mutate(max_ndays = ifelse(ndays == max(ndays), max(ndays), NA)) %>% 
  ungroup()  

save(df_10US, file = "DEATHS US Greater 10.Rdata")