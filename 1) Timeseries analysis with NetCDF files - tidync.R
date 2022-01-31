
# code for using tidync to extract data from NetCDF files.
# Example below using an SST dataset:
# NOAA Optimum Interpolation (OI) Sea Surface Temperature (SST) V2
# https://psl.noaa.gov/data/gridded/data.noaa.oisst.v2.html

library(tidync)
library(ggplot2)
library(tidyverse)

# Example 1: extract SST time-series from a single location within the NOAA dataset (1x1 grid cells)
# data is split into two time-periods (1981-1989, 1990=present), load seperately

# i) load the 1981-1989 dataset ("https://downloads.psl.noaa.gov/Datasets/noaa.oisst.v2/sst.wkmean.1981-1989.nc")
NOAA.sst.data.pre.1990 <- tidync("/Users/hydnophora/Downloads/sst.wkmean.1981-1989.nc") # load data through tidync
print(NOAA.sst.data) # explore netcdf file: dimensions shows 1) Longitude, 2) Latitude, 3) time

# use hyper_filter to filter dimensions for latitude and longitude
# note: multiple comparisons (e.g. filtering within latitude) must occur in one expression (see ?hyper_filter for details)
# including hyper_tibble in the pipe allows for extracting the NetCDF files as expanded table (tibble, see ?hyper_tibble for details)

NOAA.sst.data.pre.1990.subset <- NOAA.sst.data.pre.1990 %>% hyper_filter(lat = lat < -17 & lat > -18) %>% 
                                          hyper_filter(lon = lon < 330 & lon > 329) %>% hyper_tibble()

# use as.Date to convert numeric time into a date formate
NOAA.sst.data.pre.1990.subset <- NOAA.sst.data.pre.1990.subset %>% mutate(time=as.Date(time, origin = "1800-01-01"))


# ii) load the 1990-present dataset ("https://downloads.psl.noaa.gov/Datasets/noaa.oisst.v2/sst.wkmean.1990-present.nc")
NOAA.sst.data.post.1990 <- tidync("/Users/hydnophora/Downloads/sst.wkmean.1990-present.nc") # load data through tidync

NOAA.sst.data.post.1990.subset <- NOAA.sst.data.post.1990 %>% hyper_filter(lat = lat < -17 & lat > -18) %>% #filter by lat/long
                                              hyper_filter(lon = lon < 330 & lon > 329) %>% hyper_tibble()

NOAA.sst.data.post.1990.subset <- NOAA.sst.data.post.1990.subset %>% mutate(time=as.Date(time, origin = "1800-01-01"))

# 3) combine datasets and plot
NOAA.sst.data.combined <- bind_rows(NOAA.sst.data.pre.1990.subset, NOAA.sst.data.post.1990.subset)

ggplot() + geom_line(data=NOAA.sst.data.combined, aes(x=time, y=sst)) + theme_bw()


