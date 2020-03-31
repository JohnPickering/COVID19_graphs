# Covid Functions
# These functions originated from from https://joachim-gassen.github.io/2020/03/tidying-the-john-hopkins-covid-19-data/.  
# 1 April additional function to enable US state data to be graphed

clean_jhd_to_long <- function(df) {
  df_str <- deparse(substitute(df))
  var_str <- substr(df_str, 1, str_length(df_str) - 4)
  
  df %>% group_by(`Country/Region`) %>%
    filter(`Country/Region` != "Cruise Ship") %>%
    select(-`Province/State`, -Lat, -Long) %>%
    mutate_at(vars(-group_cols()), sum) %>% 
    distinct() %>%
    ungroup() %>%
    rename(country = `Country/Region`) %>%
    pivot_longer(
      -country, 
      names_to = "date_str",
      values_to = var_str
    ) %>%
    mutate(date = mdy(date_str)) %>%
    select(country, date, !! sym(var_str)) 
}

#########

clean_jhd_to_long_US <- function(df) {
  df_str <- deparse(substitute(df))
  var_str <- substr(df_str, 1, str_length(df_str) - 3)
  ifelse(df_str == "confirmed_US",
         {df <- df %>% select(-`Country_Region`, -Lat, -`Long_`,  -Admin2, -UID, -iso2, -iso3, -code3, -FIPS, -Combined_Key) },
         {df <- df %>% select(-`Country_Region`, -Lat, -`Long_`, -Population, -Admin2, -UID, -iso2, -iso3, -code3, -FIPS, -Combined_Key)}
  )
  df %>% group_by(`Province_State`) %>%
    filter(`Province_State` != "Cruise Ship") %>%
    mutate_at(vars(-group_cols()), sum) %>% 
    distinct() %>%
    ungroup() %>%
    rename(state = `Province_State`) %>%
    pivot_longer(
      -state, 
      names_to = "date_str",
      values_to = var_str
    ) %>%
    mutate(date = mdy(date_str)) %>%
    select(state, date, !! sym(var_str)) 
}

#########
extract_country <- function(my_country, df) {
  country_change <- df %>% 
    filter(country == my_country) %>% 
    select(change)
  return(country_change)
}
