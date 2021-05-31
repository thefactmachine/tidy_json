# https://tidyr.tidyverse.org/articles/rectangle.html#game-of-thrones-characters-1

library(tidyr)
library(dplyr)
library(repurrrsive)


discs <- tibble(disc = discog) %>% 
  unnest_wider(disc) %>% 
  mutate(date_added = as.POSIXct(strptime(date_added, "%Y-%m-%dT%H:%M:%S"))) 
discs

# 155 x 5
discs %>% dim()

# this fails because there is an id column inside basic information.

discs %>% unnest_wider(basic_information)


# We can quickly see what’s going on by setting names_repair = "unique":

discs %>% unnest_wider(basic_information, names_repair = "unique")

# The problem is that basic_information repeats the id column that’s also stored at the top-level, so we can just drop
# that

discs %>% 
  select(!id) %>% 
  unnest_wider(basic_information)

# or we could use hoist()
discs %>% 
  hoist(basic_information,
        title = "title",
        year = "year",
        label = list("labels", 1, "name"),
        artist = list("artists", 1, "name")
  )

discs$basic_information[[1]] %>% View()

discs %>% 
  hoist(basic_information,
        title = "title",
        year = "year",
        label = list("labels", 1, "name"),
        artist = list("artists", 1, "name")
  )

# A more systematic approach would be to create separate tables for artist and label:

discs %>% 
  hoist(basic_information, artist = "artists") %>% 
  select(disc_id = id, artist) %>% 
  unnest_longer(artist) %>% 
  unnest_wider(artist)

discs %>% 
  hoist(basic_information, format = "formats") %>% 
  select(disc_id = id, format) %>% 
  unnest_longer(format) %>% 
  unnest_wider(format) %>% 
  unnest_longer(descriptions)





