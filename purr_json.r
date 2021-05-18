library(tidyverse)
library(jsonlite)
library(listviewer)

# https://themockup.blog/posts/2020-05-22-parsing-json-in-r-with-jsonlite/

url_json <- "https://site.web.api.espn.com/apis/fitt/v3/sports/football/nfl/qbr?region=us&lang=en&qbrType=seasons&seasontype=2&isqualified=true&sort=schedAdjQBR%3Adesc&season=2019"

raw_json <- jsonlite::fromJSON(url_json)

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

cbind.data.frame(split_vec)

# convert to 1 row x 10 column data.frame.
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

# ===========================================================================
# attempt 2










