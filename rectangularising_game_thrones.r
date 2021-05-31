

library(tidyr)
library(dplyr)
library(repurrrsive)

# there are 30 rows. And a named list for each one.
# each list has 18 elements.
# there is only one column
chars <- tibble(char = got_chars)

# now we have 30 rows by 18 columns.
# some columns are simple types while some are simple types.
chars2 <- chars %>% unnest_wider(char)
chars2

# just show the list types.
chars2 %>% select_if(is.list)

# "books" is a list of character vectors   Uenven length.
# "tvSeries is a list of chacter vectors.  Uneven length. Nulls allowed.
# "name" is unique (simple type)

chars2 %>% 
  select(name, books, tvSeries) %>% 
  # this will result in "name", "media", "value" (i.e. list)  about 60 rows.
  # is uniquen by "name" and "media"
  pivot_longer(c(books, tvSeries), names_to = "media", values_to = "value") %>% 
  # this will repeat "name" and "media" and then peel out "value"  180 rows.
  unnest_longer(value)

