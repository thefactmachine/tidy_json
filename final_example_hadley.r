

rm(list = ls())
library(tidyverse)
library(jsonlite)
library(listviewer)


# original example.....

str_path_raw <- 
  paste0("/Users/markthekoala/Library/",
"Mobile Documents/com~apple~CloudDocs/tidy_json/raw_file.json")
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

url_json <- paste0("https://site.web.api.espn.com/apis/fitt/v3/sports/", 
  "football/nfl/qbr?region=us&lang=en&qbrType=seasons&seasontype=2&",
  "isqualified=true&sort=schedAdjQBR%3Adesc&season=2019")

# =============================================================================
# =============================================================================
# =============================================================================


# get the raw json into R
raw_json_list <- jsonlite::read_json(url_json)

str(raw_json_list, max.level = 1)

# compare to 

# /athletes/array[1:30]/athlete[19]
listviewer::jsonedit(raw_json_list)

# list 10
category_names <- pluck(raw_json_list, "categories", 1, "labels")

# 30 x 1 (list) Row name is athlete

# step 1
athletes <- tibble(athlete = pluck(raw_json_list, "athletes"))

# Step 2 --- 30 x 1
# single column. The column contains a list. This list contains 2 sub lists.

# step 2 has two columns: "athlete" and "categories"
df_step_2 <- athletes %>% unnest_wider(athlete)

# so look at the column "athlete" and extract the three simple types
# leave the remaining field names inside the list.  And leave the lists
# inside the data.frame
df_step_3 <- df_step_2 %>% 
  hoist(athlete,"displayName", "teamName", "teamShortName")

# the column "categories" is an array of 1 element... look at this:
listviewer::jsonedit(df_step_3)

# and this
df_step_3 %>% head(2)

# and the single element of the array is an object with four fields
df_step_4 <- df_step_3 %>% unnest_longer(categories) 

# "totals" becomes a second columns. It is an unamed list of 10 elements.
df_step_5 <- df_step_4 %>% tidyr::hoist(categories, "totals")

# "totals" was previously a list of characters....now it is a list
# of numbers
# seee here:
df_step_5$totals[[1]][[1]]

df_step_6 <- df_step_5 %>% mutate(totals = map(totals, as.double))

# now see
df_step_6$totals[[1]][[1]]

df_step_7 <- df_step_6 %>% mutate(totals = map(totals, set_names, category_names))

# And now...
df_step_7$totals[[1]]

# this just widens out our single column of named doubles.  Had 1 column
# and now have 10 columns
df_step_8 <- df_step_7 %>% tidyr::unnest_wider(totals)

# inside athlete ... there is an object called "headshot" with a field 
# called "href"  We extract this component and store it in the column called
# "headshot"
df_step_9 <- df_step_8 %>% hoist(athlete, headshot = list("headshot", "href")) 

# =============================================================================
# =============================================================================

# pluck
# unnest_wider
# unnest_longer
# hoist (simple)

# =============================================================================
# unnest_wider, # unnest_longer

# start with 30 x 6 data.frame [step 7]  ... now run this
# and our single column is split out into 10 columns resulting in 9
# extra columns.  So we have 30 x 15
df_step_7 %>% tidyr::unnest_wider(totals) %>% dim()

# so using unnest_longer ... we have each row being duplicated 10 times
# this is the row count: 30 x 10 ==> 300.  Our totals is a named vector
# we we have two columns for this.  So 6 columns becomes 7 columns.
df_step_7 %>% tidyr::unnest_longer(totals) %>% dim()

df_step_7 %>% tidyr::unnest_longer(totals) 

# =============================================================================
# unnest_wider, # unnest_longer

obj1 <- list("a", list(1, elt = "foo"))
obj2 <- list("b", list(2, elt = "bar"))
x <- list(obj1, obj2)
View(x)








jsonlite::parse_json('{"name":"John", "age":30, "car":null}')







jsonedit(df_step_8)






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



