# unnest_longer() takes each element of a list-column and makes a new row.
# unnest_wider() takes each element of a list-column and makes a new column.
# unnest_auto() guesses whether you want unnest_longer() or unnest_wider().
# hoist() is similar to unnest_wider() but only plucks out selected components, and can reach down multiple levels.

library(tidyr)
library(dplyr)
library(repurrrsive)

# the following contains information about six users...

# 6 rows and 1 column. The column is called "user"
users <- tibble(user = gh_users)

# get the first row from the "user" column.
users$user[[1]] %>% names()

# here this is 30.
users$user[[1]] %>% names() %>% length()

# now 
users %>% unnest_wider(user)

# Introducing Hoist

# hoist() removes the named components from the user list column.
users %>% hoist(user, followers = "followers", login = "login", url = "html_url")


repos <- tibble(repo = gh_repos)

# have a single column called "repo" and this is an array (in JS)  

# repos is a 6 row x 1 colum ("repo")
# following is a length of each row:
# 30, 30, 30, 26, 30, 30

listviewer::jsonedit(repos)

# this becomes 176 rows.
# each item contains a list which is 68 elements long....
new_repos <- repos %>% unnest_longer(repo)

# these are the names of the 68 elements.
new_repos$repo[[1]] %>% names()

new_repos$repo %>% length() 

# traverse through the data.frame and get a count.
vct_length <- 1:length(new_repos$repo) %>% 
  sapply(function(x) new_repos$repo[[x]] %>% length())

# get the names
new_repos$repo[[1]] %>% names() %>% sort()


# results in a 176 x 5 data.frame.
new_repos %>% 
  hoist(repo, 
       # owner is a list and login is a character
        login = c("owner", "login"),
       # name is character vector
       name = "name",
       # homepage is null
       homepage = "homepage",
       # watchers_count is integer
       watchers = "watchers_count"
        )

# the above shows how to unravel the c("owner", "login") thingy....

# there are 17 names here....
new_repos$repo[[1]]$owner %>% names()

repos %>% 
  hoist(repo, owner = "owner") %>% 
  unnest_wider(owner)

#  unnest_auto(repo) is available too.  

