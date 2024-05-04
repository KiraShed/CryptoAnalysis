install.packages("crypto2")
install.packages("tidyverse")
library(crypto2)
library(tidyverse)
library(lubridate) # working with date/times
library(rvest) # web scraping
library(stats) # statistics package
library(magrittr) # operators that reduce development time 
library(quantmod) # package useful for quantitative trading & research
library(tidyquant) # a wrapper with convenient functions 
library(dendextend) # a package for creating visually appealing dendrograms
library(PortfolioAnalytics) # a package to quickly evaluate portfolio performance
library(janitor) #used in the tutorial for the "clean_names()" function

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

#Add dataset with a description of the crypto
crypto_info <-  crypto_info()
crypto_info %>% write_rds("crypto_info.rds")
crypto_info %>% glimpse 

#Data Visualisation of the main dataset all_coins_mcsort
all_coins_mcsort %>% 
  filter(name == "Bitcoin") %>% 
  ggplot(aes(date,USD_price))+
  geom_line()
plot(all_coins_mcsort$date, all_coins_mcsort$USD_price)

top_50_by_marketcap <- 
  crypto_list() %>% #list all cryptos agaon
  arrange(rank) %>% #arrange the based on market cap rank
  slice(1:50) #select rows 1 to 50

top_50_crypto_prices <-
  crypto_history(top_50_by_marketcap) %>% #get data for all 100 coins
  mutate(timestamp = as.Date(as.character(timestamp))) #fix the timestamp into a date object

#Plot TOP50
top_50_crypto_prices %>% 
  ggplot(aes(timestamp,close, col = name))+
  geom_line()

#SECTION 2 - CALCULATE CRYPTOCURRENCY RETURNS
crypto_daily_returns <- 
  top_50_crypto_prices %>% 
  arrange(symbol, timestamp) %>% #make sure to arrange the data first so the lag calculations aren't erroneous
  group_by(symbol) %>%  
  mutate(daily_return = close/lag(close, 1)-1) %>% #calculate the return in prices
  select(timestamp, name, symbol, daily_return) #select a subset of the columns - not 100% neccecary

crypto_daily_returns #view the final results


#SECTION 3 - WORKING WITH HIERARCHICAL CLUSTERING ALGORITHM

hc <- 
  crypto_daily_returns %>% 
  pivot_wider(id_cols = timestamp, names_from = name, values_from = daily_return) %>% #make the data wide, instead of long
  select(-timestamp) %>% #remove the timestamp - we want to exclude these from the calculation
  cor(use = 'complete.obs') %>% #correlation matrix 
  abs() %>% #absolute value
  dist() %>% #distance matrix
  hclust() #hierarchical clustering

hc %>% 
  as.dendrogram() %>% #convert clustering object into dendrogram
  plot() #view the results

number_clusters <- 9 #how many clusters do you want to select

hc %>% 
  as.dendrogram() %>% 
  color_branches(k = number_clusters) %>% 
  color_labels(k = number_clusters) %>% 
  set('labels_cex', 1) %>% 
  # plot()
  as.ggdend() %>% 
  ggplot() +
  labs(title = 'Dendrogram of the top 50 Cryptocurrencies by market cap')

