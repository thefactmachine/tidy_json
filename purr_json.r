rm(list = ls())
library(tidyverse)
library(jsonlite)
library(listviewer)

# https://themockup.blog/posts/2020-05-22-parsing-json-in-r-with-jsonlite/

url_json <- "https://site.web.api.espn.com/apis/fitt/v3/sports/football/nfl/qbr?region=us&lang=en&qbrType=seasons&seasontype=2&isqualified=true&sort=schedAdjQBR%3Adesc&season=2019"

str_path_raw <- "/Users/markthekoala/Library/Mobile Documents/com~apple~CloudDocs/tidy_json/raw_file.json"


raw_json <- jsonlite::fromJSON(str_path_raw)

str(raw_json, max.level = 1)

listviewer::jsonedit(raw_json)

raw_json$athletes %>% str(max.level = 1)

raw_json$athletes$athlete %>% dim()

raw_json$athletes$athlete %>% str(max.level = 1)

raw_json$athletes$categories %>% str(max.level = 1)

raw_json$athletes$categories %>% length()

raw_json$athletes$categories[[1]] %>% names()
# "name", "displayName", "totals", "ranks"   

# extract the totals (3rd element) for the 1st category.
raw_json$athletes$categories[[1]][3]

raw_json$athletes$categories[[1]][3][[1]]

# ===========================================================================
# attempt 1
# 30 x  3 data.frame... 
df_interest <- raw_json$athletes$athlete[c("displayName", "teamName", "teamShortName")]
length_df <- nrow(df_interest)
pbp_out <- data.frame()

# "TQBR" "PA"   "QBP"  "TOT"  "PAS"  "RUN"  "EXP"  "PEN"  "QBR"  "SAC" 
category_names <- raw_json[["categories"]][["labels"]][[1]]

# here are the totals for the first player
aa <- raw_json$athletes$categories[[1]]$totals[[1]] %>% as.double()
split(aa, category_names)

# convert to 1 row x 10 column data.frame.
# just diplaying its functionality here.
split(aa, category_names) %>% cbind.data.frame()

for (i in 1:length_df){
  # grab each QBs stats and convert to a vector of type double
  raw_vec <- as.double(raw_json$athletes$categories[[i]]$totals[[1]])
  
  # split each stat into it's own list with the proper name
  split_vec <- split(raw_vec, category_names)
  
  # convert the list into a dataframe 
  pbp_df_loop <- cbind.data.frame(split_vec)
  
  # combine the 30 QB's stats into the empty data.frame
  pbp_out <- rbind(pbp_out, pbp_df_loop)
}


pbp_out

# combine our loop-created df w/ the QB names/team
final_loop_df <- cbind(df_interest, pbp_out)

library(dplyr)

# take a peek at the result!
head(final_loop_df)

glimpse(final_loop_df)


# ===========================================================================
# attempt 2

# using apply functions. 
# did not pre-allocate a returing data.frame ...so the following maybe slower
# than compared to the for loop.

# extract the core name dataframe
# list of athletes.
df_interest <- raw_json$athletes$athlete[c("displayName", "teamName", "teamShortName")]

# how many rows?
length_df <- nrow(df_interest)

# category names again. These are the keys for a numeric vector of the same
# length [10]
category_names <- raw_json[["categories"]][["labels"]][[1]]

# create a function to apply
qbr_stat_fun <- function(qb_num){
  # grab each QBs stats and convert to a vector of type double length [10]
  raw_vec <- as.double(raw_json$athletes$categories[[qb_num]]$totals[[1]])
  
  # split each stat into it's own list with the proper name
  # this is a named list. Could be a named vector.
  split_vec <- split(raw_vec, category_names)
  
  # return the lists
  split_vec
}

# use apply to generate list of lists
list_qbr_stats <- lapply(1:length_df, qbr_stat_fun)

# Combine the lists into a dataframe
list_pbp_df <- do.call("rbind.data.frame", list_qbr_stats)

# cbind the names with the stats
cbind(df_interest, list_pbp_df) %>% glimpse()

# ===========================================================================
# Enter Purrr
# pluck is a form of "[[x]]"
# equivalent to raw_json[["athletes"]][["athlete"]]


# Viewing functions
str(raw_json, max.level = 1)

listviewer::jsonedit(raw_json)

#df
raw_json %>% purrr::pluck("athletes", "athlete") %>% class()
  
# 30 x 19
raw_json %>% purrr::pluck("athletes", "athlete") %>% dim()


# equivalent to raw_json[["athletes"]][["athlete"]][["headshot"]]
raw_json %>% purrr::pluck("athletes", "athlete", "headshot") %>% glimpse()

# 30 rows 2 columns
raw_json %>% purrr::pluck("athletes", "athlete", "headshot") %>% dim()

# xx is 30 x 2 data.frame 
xx <- raw_json$athletes 
listviewer::jsonedit(xx)



# get names of the QBR categories with pluck. Pull out first array.  
# The object under "labels" an an Array (it is unnamed). So pull out by number

category_names <- pluck(raw_json, "categories", "labels", 1)

# /athletes/categories/[array - 0:29]/totals/[array 1]

# returns a vector of length 10
purrr::pluck(raw_json, "athletes", "categories", 3, "totals", 1) 


# Get the QBR stats by each player (row_n = row number of player in the df)
get_qbr_data <- function(row_n) {
  purrr::pluck(raw_json, "athletes", "categories", row_n, "totals", 1) %>% 
    # convert from character to double
    as.double() %>% 
    # assign names from category 1 x 10 vector
    set_names(nm = category_names)
}

# named vector
get_qbr_data(1)



# ==========================================================================
# put it all together........

# create the dataframe and tidy it up
pbp_df <- pluck(raw_json, "athletes", "athlete") %>%
  # convert to tibble
  as_tibble() %>%
  # select columns of interest
  select(displayName, teamName:teamShortName, headshot)

# print it
pbp_df

# Now we can use our get_qbr_data() to do just that and grab the data from the
# categories/totals portion of the JSON
# All that is left is dealing with that pesky headshot column!

# returns a 10 element list
map(5, get_qbr_data)

# Take our pbp_df
# there are 30 rows
wide_pbp_df <- pbp_df %>%
  # and then map across it to get the QBR data
  mutate(data = map(row_number(), get_qbr_data)) %>% 
  # and then unnest the list column we created
  unnest_wider(data)

wide_pbp_df %>% 
  glimpse()

# We can use pluck one more time to get the href column from within headshot, 
# which allows us to extract just the URL and not the repeated player name from 
# that list-dataframe column (headshot). unpack() is also really nice normally 
# but since the headshot dataframe has a duplicate column, 
# it requires additional dropping of columns

# show the structure. The column headshot is a data.frame with two columns:
# "href" and "alt"
wide_pbp_df %>% str()

# ==== version 1
final_pluck <- wide_pbp_df %>% 
  # we can pluck just the `href` column
  mutate(headshot = pluck(headshot, "href"))

final_pluck %>% glimpse()

# ===== another way 2=================>>>>>>>>
final_unpack <- wide_pbp_df %>% 
  unpack(headshot) %>% 
  # unpack includes the alt column as well
  select(everything(), headshot = href, -alt)

final_unpack %>% glimpse()

# another way 3
final_base <- wide_pbp_df %>% 
  # we can use traditional base R column selection
  mutate(headshot = headshot[["href"]])

# another way 4
final_join <- wide_pbp_df %>% 
  # could also do a join
  left_join(wide_pbp_df$headshot, by = c("displayName" = "alt")) %>% 
  # but have to drop and do additional cleanup
  select(-headshot, displayName:teamShortName, headshot = href, TQBR:SAC)

# all are the same!
c(all.equal(final_pluck, final_unpack),
  all.equal(final_pluck, final_base),
  all.equal(final_pluck, final_join))

# ==========================================================================
# ==========================================================================
# One more example ==============

# If you are using the latest version of tidyr (1.1) - check out Hadley’s approach to this!
# Note that he is using jsonlite::read_json() rather than fromJSON, this 
# doesn’t simplify and keeps everything as it’s natural list-state. 
# With tidyr::unnest() and tidyr::hoist() this is easy to work with!

# Rectangling guide:   https://tidyr.tidyverse.org/articles/rectangle.html

library(tidyverse)
library(jsonlite)

# link to the API output as a JSON file
url_json <- "https://site.web.api.espn.com/apis/fitt/v3/sports/football/nfl/qbr?region=us&lang=en&qbrType=seasons&seasontype=2&isqualified=true&sort=schedAdjQBR%3Adesc&season=2019"

# get the raw json into R
raw_json_list <- jsonlite::read_json(url_json)

library(listviewer)

listviewer::jsonedit(raw_json_list)


# get names of the QBR categories
category_names <- pluck(raw_json_list, "categories", 1, "labels")

# create tibble out of athlete objects
athletes <- tibble(athlete = pluck(raw_json_list, "athletes"))


# ==========================================================================
# explanation code...the following unpacks the long qbr_hadley code below

# this contains a single column called "athlete" Within this column are 
# two named lists: "athlete" and "categories"
listviewer::jsonedit(athletes)

# this just displays "athlete" and "categories"
athletes %>% unnest_wider(athlete) %>% head() %>% View()

# fields "displayName", "teamName", "teamShortName" are simple types.
# these are extracted as the first three columns The original lists "athletes"
# and "categories" are still columns
# 30 x 5
athletes %>% unnest_wider(athlete) %>%
  hoist(athlete, "displayName", "teamName", "teamShortName") %>% View()

test_a <- athletes %>% 
  unnest_wider(athlete) %>% 
  hoist(athlete, "displayName", "teamName", "teamShortName") 

listviewer::jsonedit(test_a)


test_b <- athletes %>% 
  unnest_wider(athlete) %>% 
  hoist(athlete, "displayName", "teamName", "teamShortName") %>% 
  unnest_longer(categories) 

listviewer::jsonedit(test_b)
# ==========================================================================
# ==========================================================================


qbr_hadley <- athletes %>% 
  unnest_wider(athlete) %>% 
  hoist(athlete, "displayName", "teamName", "teamShortName") %>% 
  unnest_longer(categories) %>% 
  hoist(categories, "totals") %>% 
  mutate(totals = map(totals, as.double),
         totals = map(totals, set_names, category_names)) %>% 
  unnest_wider(totals) %>% 
  hoist(athlete, headshot = list("headshot", "href")) %>% 
  select(-athlete, -categories)

# Is it the same as my version?
all.equal(final_pluck, qbr_hadley)

# another finally ====> another way ===================================
library(tidyverse)
library(jsonlite)

# link to the API output as a JSON file
url_json <- "https://site.web.api.espn.com/apis/fitt/v3/sports/football/nfl/qbr?region=us&lang=en&qbrType=seasons&seasontype=2&isqualified=true&sort=schedAdjQBR%3Adesc&season=2019"

# get the raw json into R
raw_json <- jsonlite::fromJSON(url_json)

# get names of the QBR categories
category_names <- pluck(raw_json, "categories", "labels", 1)

# Get the QBR stats by each player (row_n = player)
get_qbr_data <- function(row_n) {
  purrr::pluck(raw_json, "athletes", "categories", row_n, "totals", 1) %>% 
    as.double() %>% 
    set_names(nm = category_names)
}

# create the dataframe and tidy it up
ex_output <- pluck(raw_json, "athletes", "athlete") %>%
  as_tibble() %>%
  select(displayName, teamName:teamShortName, headshot) %>%
  mutate(data = map(row_number(), get_qbr_data)) %>% 
  unnest_wider(data) %>% 
  mutate(headshot = pluck(headshot, "href"))

glimpse(ex_output)

# ============================================================================
# ============================================================================
# ============================================================================
# ============================================================================
# Hadley Wickhams example:
# link to the API output as a JSON file
url_json <- "https://site.web.api.espn.com/apis/fitt/v3/sports/football/nfl/qbr?region=us&lang=en&qbrType=seasons&seasontype=2&isqualified=true&sort=schedAdjQBR%3Adesc&season=2019"

# get the raw json into R
raw_json_list <- jsonlite::read_json(url_json)

# get names of the QBR categories
category_names <- pluck(raw_json_list, "categories", 1, "labels")


# create tibble out of athlete objects
athletes <- tibble(athlete = pluck(raw_json_list, "athletes"))

qbr_hadley <- athletes %>% 
  unnest_wider(athlete) %>% 
  hoist(athlete, "displayName", "teamName", "teamShortName") %>% 
  unnest_longer(categories) %>% 
  hoist(categories, "totals") %>% 
  mutate(totals = map(totals, as.double),
         totals = map(totals, set_names, category_names)) %>% 
  unnest_wider(totals) %>% 
  hoist(athlete, headshot = list("headshot", "href")) %>% 
  select(-athlete, -categories)

# ===========================================================================
# TO long didn't read =======================================================
# ===========================================================================

# TLDR

library(tidyverse)
library(jsonlite)

# link to the API output as a JSON file
url_json <- "https://site.web.api.espn.com/apis/fitt/v3/sports/football/nfl/qbr?region=us&lang=en&qbrType=seasons&seasontype=2&isqualified=true&sort=schedAdjQBR%3Adesc&season=2019"

# get the raw json into R
raw_json <- jsonlite::fromJSON(url_json)

# get names of the QBR categories
category_names <- pluck(raw_json, "categories", "labels", 1)

# Get the QBR stats by each player (row_n = player)
get_qbr_data <- function(row_n) {
  purrr::pluck(raw_json, "athletes", "categories", row_n, "totals", 1) %>% 
    as.double() %>% 
    set_names(nm = category_names)
}

# create the dataframe and tidy it up
ex_output <- pluck(raw_json, "athletes", "athlete") %>%
  as_tibble() %>%
  select(displayName, teamName:teamShortName, headshot) %>%
  mutate(data = map(row_number(), get_qbr_data)) %>% 
  unnest_wider(data) %>% 
  mutate(headshot = pluck(headshot, "href"))

glimpse(ex_output)

