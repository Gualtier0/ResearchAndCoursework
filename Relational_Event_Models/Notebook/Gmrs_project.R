library(torch)
library(tidyverse)
library(dplyr)
library(mgcv)
library(tidyr)
library(purrr)

df0<-load("/Users/gualtieromarencoturi/Desktop/Relation event model/exploratory datas/Invasionds.RData")
#prepping the dataset



#shuffle
df1 = sample(1:nrow(dat.gam),size=nrow(dat.gam),replace = F)

df2 = dat.gam[df1,]

#add origin
origin_df1= subset(native, select = -c(1) ) 
orig_unique1 <- origin_df1 %>%
  distinct(sp.num, .keep_all = TRUE)

native_renamed1 <-orig_unique1 %>%
  rename(sp1.num = sp.num , r_orig1.num = r.num, r_orig1 = region)
native_renamed2 <- orig_unique1 %>%
  rename(sp2.num = sp.num, r_orig2.num = r.num, r_orig2 = region)

df_joined <- left_join(df2, native_renamed1, by = "sp1.num" )
df3 <- left_join(df_joined, native_renamed2, by = "sp2.num" )

#add temp
#do the same as up for tomorrow
temp_unique <- data_temperature %>%
  distinct(X, .keep_all = TRUE)

df_renamed1 <- temp_unique %>%
  rename(r1 = X, temp_r1 = temp)
df_renamed2 <- temp_unique %>%
  rename(r2 = X, temp_r2 = temp)
df_renamed3 <- temp_unique %>%
  rename(r_orig1 = X, temp_r_orig1 = temp)
df_renamed4 <- temp_unique %>%
  rename(r_orig2 = X, temp_r_orig2 = temp)

df_joined1 <- left_join(df3, df_renamed1, by = "r1")
df_joined2 <- left_join(df_joined1, df_renamed2, by = "r2")
df_joined3 <- left_join(df_joined2, df_renamed3, by = "r_orig1")
df_joined4 <- left_join(df_joined3, df_renamed4, by = "r_orig2")

#compute distance
# ordina indice
nazioni <- unique(c(df_joined4$r1, df_joined4$r_orig1, df_joined4$r2, df_joined4$r_orig2))
nazioni <- nazioni[order(match(nazioni, colnames(data_distance)))]

# funzione per ottenere l'indice di una nazione
get_index <- function(nation, nation_list) {
  match(nation, nation_list)
}

# funzione per ottenere la distanza dalla matrice
get_distance <- function(nation1, nation2, dist_matrix, nation_list) {
  index1 <- get_index(nation1, nation_list)
  index2 <- get_index(nation2, nation_list)
  dist_matrix[index1, index2]
}

#ottieni le colonne
df_complete <- df_joined4 %>%
  rowwise() %>%
  mutate(
    distancefromorig1 = get_distance(r1, r_orig1, data_distance, nazioni),
    distancefromorig2 = get_distance(r2, r_orig2, data_distance, nazioni)
  ) %>%
  ungroup()

#drop na
df_final <- df_complete %>%
  drop_na()

#df2 = subset(df3, select = -c(1,2,3,4,5,6) )
#shuffle again
dfx = sample(1:nrow(df_final),size=nrow(df_final),replace = F)

df2_final = df_final[dfx,]

#one vector
n<-nrow(df2_final)
one<-rep(1,n)

#events assignement
#df_final$year, df_final$dt1, df_final$temp_r1, df_final$r_orig1.num, df_final$temp_r_orig1
M.dt <- cbind(df2_final$dt1, df2_final$dt2)
M.dtemp <- cbind(df2_final$temp_r1, df2_final$temp_r2)
M.distfromorig <- cbind(df2_final$distancefromorig1, df2_final$distancefromorig2)
M.dtemporig <- cbind(df2_final$temp_r_orig1, df2_final$temp_r_orig2)

M.one <- cbind(one, -one)

options(na.action="na.omit")
#model 
insects.gam <- gam(one~ -1 + s(M.distfromorig, by=M.one)+ s(M.dt, by=M.one)+ s(M.dtemp, by=M.one)+ s(M.dtemporig, by=M.one)
                  , family=binomial)

summary(insects.gam)
plot(insects.gam)
BIC(insects.gam)
AIC(insects.gam)

#model2
insects.gam2 <- gam(one~ -1 + s(M.distfromorig, by=M.one)+ s(M.dt, by=M.one)+ s(M.dtemp, by=M.one)+ s(M.dtemporig, by=M.one)
                   , family=binomial)

summary(insects.gam2)
plot(insects.gam2)
BIC(insects.gam2)
AIC(insects.gam2)
