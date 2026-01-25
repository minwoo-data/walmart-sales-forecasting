# src/01_load_and_clean.R
source("src/00_setup.R")

file_path <- "data/raw/walmart.csv"
df_wal <- read.csv(file_path, header = TRUE)

# Overview
head(df_wal)
tail(df_wal)

# Summary
glimpse(df_wal)
skim(df_wal)
summary(df_wal)

# Missing / duplicates
colSums(is.na(df_wal))
duplicated_rows <- df_wal[duplicated(df_wal), ]
nrow(duplicated_rows)

# Negative purchase check
if ("Purchase" %in% names(df_wal)) {
  negative_purchase <- df_wal %>% dplyr::filter(Purchase < 0)
  cat("Negative Purchase rows:", nrow(negative_purchase), "\n")
}

# Rename to lowercase
names(df_wal) <- tolower(names(df_wal))

# Unique values in categorical vars
cat_vars <- c("gender", "age", "city_category", "stay_in_current_city_years")
cat_vars <- intersect(cat_vars, names(df_wal))

for (var in cat_vars) {
  cat("Unique values in", var, ":\n")
  print(unique(df_wal[[var]]))
  cat("\n")
}

# Convert to factor
factor_candidates <- c("gender", "age", "city_category", "stay_in_current_city_years",
                       "marital_status", "occupation", "product_category")

for (v in intersect(factor_candidates, names(df_wal))) {
  df_wal[[v]] <- as.factor(df_wal[[v]])
}

saveRDS(df_wal, "data/processed/df_wal_clean.rds")
cat("Saved: data/processed/df_wal_clean.rds\n")
