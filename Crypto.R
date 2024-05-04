install.packages("crypto2")
install.packages("tidyverse")
library(crypto2)
library(tidyverse)

# crypto_global_quotes()
# Retrieves historical quotes for the global aggregate market

# crypto_history()
# Get historic crypto currency market data

# crypto_info()
# Retrieves info (urls, logo, description, tags, platform, date_added, notice, status) on CMC for given id or slug

# crypto_list() fiat_list()
# Retrieves name, CMC id, symbol, slug, rank, an activity flag as well as activity dates on CMC for all coins

# crypto_listings()
# Retrieves name, CMC id, symbol, slug, rank, an activity flag as well as activity dates on CMC for all coins

# exchange_info()
# Retrieves info (urls,logo,description,tags,platform,date_added,notice,status) on CMC for given exchange slug

# exchange_list()
# Retrieves name, CMC id, symbol, slug, rank, an activity flag as well as activity dates on CMC for all coins

# ?crypto2


ls <-  crypto_listings()
fls <-  fiat_list()
ls %>% glimpse
?crypto_listings
fls %>% glimpse

# only download the top 100 crypto currencies based on their market capitalization
all_coins_mcsort <- crypto_listings(which="historical", quote=TRUE,
                                         end_date="20240503", interval="month", sort="market_cap",
                                          sort_dir="desc")
#Save to RDS
all_coins_mcsort %>% write_rds("all_coins_mcsort.rds")

?read_rds

#Read file from RDS
all_coins_mcsort <- read_rds("all_coins_mcsort.rds")

#View new list coins 
all_coins_mcsort %>% glimpse

#Create unique vector of coin names
all_coins <-  unique(all_coins_mcsort$name)

### IMPORT new data set
listings <- crypto_list(only_active = F, add_untracked = T)
