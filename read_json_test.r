

library(tidyverse)
library(jsonlite)
library(listviewer)

str_path <- "/Users/markthekoala/Library/Mobile Documents/com~apple~CloudDocs/tidy_json/json/test_data.json"


# parse error. Not valid JSON
vct_lines <- fromJSON(readLines(str_path))

vct_lines_raw <- readLines(str_path)



str_path_array <- "/Users/markthekoala/Library/Mobile Documents/com~apple~CloudDocs/tidy_json/json/test_data_array.json"
df_result <- fromJSON(readLines(str_path_array))
df_result %>% unnest_wider(friends)
