# src/03_feature_engineering.R
source("src/00_setup.R")
df_wal <- readRDS("data/processed/df_wal_clean.rds")

# Feature engineering
df_wal2 <- df_wal

if (all(c("age","city_category","stay_in_current_city_years") %in% names(df_wal2))) {
  df_wal2 <- df_wal2 %>%
    mutate(
      age = as.character(age),
      city_category = as.character(city_category),
      stay_in_current_city_years = as.character(stay_in_current_city_years),
      stay_in_current_city_years = gsub("4\\+", "4", stay_in_current_city_years),
      
      age_group_num = as.numeric(factor(age, levels = c("0-17","18-25","26-35","36-45","46-50","51-55","55+"))),
      city_category_num = as.numeric(factor(city_category, levels = c("A","B","C"))),
      stay_years = as.numeric(stay_in_current_city_years),
      
      city_category_num = as.factor(city_category_num)
    ) %>%
    dplyr::select(-age, -city_category, -stay_in_current_city_years)
}

# Drop IDs if exist
drop_cols <- intersect(c("user_id", "product_id"), names(df_wal2))
df_model <- df_wal2 %>% dplyr::select(-all_of(drop_cols))

# log target
df_model_log <- df_model
df_model_log$log_purchase <- log1p(df_model_log$purchase)

saveRDS(df_model, "data/processed/df_model.rds")
saveRDS(df_model_log, "data/processed/df_model_log.rds")

cat("Saved: data/processed/df_model.rds\n")
cat("Saved: data/processed/df_model_log.rds\n")
