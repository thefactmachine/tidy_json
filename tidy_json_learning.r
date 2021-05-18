library(dplyr)

library(tidyjson)

# https://qiushi.rbind.io/post/json-column-r/

options(scipen=999)

# Define a simple people JSON collection
people <- c('{"age": 32, "name": {"first": "Bob",   "last": "Smith"}}',
            '{"age": 54, "name": {"first": "Susan", "last": "Doe"}}',
            '{"age": 18, "name": {"first": "Ann",   "last": "Jones"}}')

# spread_all()
people %>% tidyjson::spread_all()

df_test <- people %>% tidyjson::spread_all()

# lets look at work bank json data included with package.
tidyjson::worldbank


worldbank %>% spread_all %>% select(regionname, totalamt)

# We can use gather_object to gather all name-value paris by name, and then 
# json_types to identify the type of JSON stored under each value, 
# and dplyr::count to aggregate across documents:

worldbank %>% gather_object %>% json_types %>% count(name, type)

# It appears that majorsector_percent is an array, 
# and so we can use enter_object to enter into it:

worldbank %>% enter_object(majorsector_percent)

# and gather_array to gather it by index

worldbank %>% enter_object(majorsector_percent) %>% gather_array

# ================================

# Define a simple people JSON collection
people <- c('{"age": 32, "name": {"first": "Bob",   "last": "Smith"}}',
            '{"age": 54, "name": {"first": "Susan", "last": "Doe"}}',
            '{"age": 18, "name": {"first": "Ann",   "last": "Jones"}}')



df_test <- people %>% tidyjson::spread_all()

# produces a tbl_json object.
df_test %>% class()

# spread_all cannot spread arrays. 
worldbank %>% spread_all()

# one column is missing.  This is majorsector_percent because its paired value
# is an array. 

# here it is:  (from row 1)
# majorsector_percent":[
#   {"Name":"Education","Percent":46},
#   {"Name":"Education","Percent":26},
#   {"Name":"Public Administration, Law, and Justice","Percent":16},
#  {"Name":"Education","Percent":12}
# ]
worldbank %>% spread_all() %>% names()

# gets the top level object names.  There are 8 of these for the first row.
worldbank[1] %>% gather_object()

# this just gets the data.types of each object.  Some objects point to other
# objects. Some point to strings. Some point to arrays. The following returns
# 8 rows.
worldbank[1] %>% gather_object() %>% json_types()

# this returns 1 for all (8 lines)
worldbank[1] %>% gather_object() %>% json_types() %>% count(name, type)

# returns 8 lines here
worldbank %>% gather_object() %>% json_types() %>% count(name, type)

# this also returns 8 lines. 
worldbank %>% gather_object() %>% json_types() %>% count(name)

# We can use enter_object to extract any name-value pair from the entire json string
# this produces 1 rows
worldbank[1] %>% enter_object(majorsector_percent) 

# this produces 4 rows.....
worldbank[1] %>% enter_object(majorsector_percent) %>% gather_array()

# this now adds two colums (Name and Percent)
worldbank[1] %>% 
  enter_object(majorsector_percent) %>% 
  gather_array() %>% 
  spread_all()


# this can be combined with the initial spread

# the following produces 1 row
worldbank[1] %>% spread_all()

# the following produces 4 rows. Some of the columns are repeated. 
worldbank[1] %>% spread_all() %>% 
  enter_object(majorsector_percent) %>% gather_array() %>% spread_all()


# Here we go. There are three rows here.
people_array <- 
  c('{"age": 32, "name": {"first": "Bob", "last": "Smith"}, "workday": ["Monday", "Tuesday"]}',
  '{"age": 54, "name": {"first": "Susan", "last": "Doe"}, "workday":["Monday", "Wednesday", "Sunday"]}',
  '{"age": 18, "name": {"first": "Ann",   "last": "Jones"}, "workday": ["Tuesday"]}')

# so this one just entirely skips "workday" There are 3 rows here.
people_array %>% spread_all()

# This one ... there are also 3 rows but workday becomes a list.
people_array %>% spread_all %>% enter_object(workday) %>% mutate(workday = ..JSON)



friends <- c('{"name": "Monica", "detail": {"job": ["chef"], "hobby": "cleaning"}}',
             '{"name": "Ross", "detail": {"job": ["paleontologist", "professor"], "hobby": "dinosaurs"}}',
             '{"name": "Chandler", "detail": {"job": ["IT procurement", "copywriter"], "hobby": "bubble bath"}}',
             '{"name": "Joey", "detail": {"job": ["actor"], "hobby": "sandwich"}}',
             '{"name": "Rachel", "detail": {"job": ["waitress", "fashion exec"], "hobby": "shopping"}}',
             '{"name": "Pheobe", "detail": {"job": ["masseuse", "musician"],   "hobby": "guitar"}}')

friends %>% 
  spread_values(
    name = jstring("name"),
    # hobby is a sub object of detail -- hobby only contains 1 element
    hobby = jstring("detail", "hobby")
  )

# job can have more than 1 element.
df_json_test <- friends %>% 
  spread_values(
    name = jstring("name"),
    hobby = jstring("detail", "hobby")
  ) %>% 
  enter_object(detail, job) %>% 
  mutate(job = ..JSON) 

df_json_test %>% str()

library(tidyr)

# 6 x 5 (1 column is the JSON)
df_json_test %>% dim()

# unpacks the list and repeats rows....
df_json_test %>% tidyr::unnest_longer(job)




# how to work with lists in data.frames.

library(readr)

setwd("/Users/zurich/Library/Mobile Documents/com~apple~CloudDocs/tidy_json")

# original data from Kaggle.  See hier:
# https://www.kaggle.com/c/ga-customer-revenue-prediction/data?select=test.csv

# this test.csv is vary large (too large for git so import it and save a small bit)
ga <- read_csv("test.csv",
               n_max = 100,
               col_types = cols_only(
                 device = col_character(),
                 geoNetwork = col_character(),
                 totals = col_character(),
                 trafficSource = col_character()
               )) 

write.csv(ga, "subset_data.csv")

# will get a warning message:
# Missing column names filled in: 'X1' [1] 
ga_ss <- read_csv("subset_data.csv")
ga_ss$X1 <- NULL

# All four columns are json columns. First let’s define function that is used 
# to parse a single json character vector:

# map_dfr ==> apply a function to each element of a list.

parse_json_col <- function(col) {
  map_dfr(col, ~ fromJSON(.) %>% as_tibble)
} 

# did not go any further with this......



