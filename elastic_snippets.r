


rm(list = ls())
library(tidyverse)
library(jsonlite)
library(listviewer)
library(elastic)

x <- connect()

plosdat <- system.file("examples", "plos_data.json", package = "elastic")


docs_bulk(x, plosdat)