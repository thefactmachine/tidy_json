

rm(list = ls())
library(tidyverse)
library(jsonlite)
library(listviewer)


# original example.....

str_path_raw <- "/Users/markthekoala/Library/Mobile Documents/com~apple~CloudDocs/tidy_json/raw_file.json"
raw_json <- jsonlite::fromJSON(str_path_raw)

listviewer::jsonedit(raw_json)

# get names of the QBR categories
category_names_orig <- pluck(raw_json, "categories", "labels", 1)


vct_test <- c("mark", "allan", "hatcher")

map_dbl(vct_test, nchar)

library(elastic)

c <- connect(host = "127.0.0.1", port = 9200)

elastic::docs_bulk(c, mtcars, index = "cars")



# =============================================================================
# Hadly
# link to the API output as a JSON file
url_json <- "https://site.web.api.espn.com/apis/fitt/v3/sports/football/nfl/qbr?region=us&lang=en&qbrType=seasons&seasontype=2&isqualified=true&sort=schedAdjQBR%3Adesc&season=2019"

# get the raw json into R
raw_json_list <- jsonlite::read_json(url_json)

# compare to 

# /athletes/array[1:30]/athlete[19]
listviewer::jsonedit(raw_json_list)

# list 10
category_names <- pluck(raw_json_list, "categories", 1, "labels")

# 30 x 1 (list) Row name is athlete
athletes <- tibble(athlete = pluck(raw_json_list, "athletes"))

library(elasticsearchr)


              # start with 30 rows and l list
qbr_hadley <- athletes %>% 
  # now 30 rows and 2 list columns ("athlete (19) "categories (1)")
  unnest_wider(athlete) %>% 
  # we have "displayName (char), teamName (char), teamShortName (char), athlete (16), categories (1)
  hoist(athlete, "displayName", "teamName", "teamShortName") %>% 
  # mystery
  unnest_longer(categories) %>% 
  
  # totals is a list of 10
  # we have "displayName (char), teamName (char), teamShortName (char), athlete (16), totals (10), categories(3)
  hoist(categories, "totals") %>% 
  
  # still have the following: 
  # "displayName (char), teamName (char), teamShortName (char), athlete (16), totals (10), categories(3)
  mutate(totals = map(totals, as.double),
         totals = map(totals, set_names, category_names)) %>% 
  # unpeel the totals
  unnest_wider(totals) %>% 
  hoist(athlete, headshot = list("headshot", "href")) %>% 
  select(-athlete, -categories)



