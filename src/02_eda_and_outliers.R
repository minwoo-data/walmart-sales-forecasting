# src/02_eda_and_outliers.R
source("src/00_setup.R")
df_wal <- readRDS("data/processed/df_wal_clean.rds")

# Helper: plot
save_plot <- function(plot_obj, filename, w = 9, h = 5) {
  ggsave(filename, plot_obj, width = w, height = h)
}

# EDA
if (all(c("age","purchase","gender") %in% names(df_wal))) {
  p1 <- ggplot(df_wal, aes(x = age, y = purchase, fill = gender)) +
    geom_bar(stat = "summary", fun = "mean", position = "dodge") +
    labs(title = "Age vs Purchase", x = "Age", y = "Average Purchase")
  save_plot(p1, "results/figures/eda_age_purchase.png")
}

if (all(c("occupation","purchase","gender") %in% names(df_wal))) {
  p2 <- ggplot(df_wal, aes(x = occupation, y = purchase, fill = gender)) +
    geom_bar(stat = "summary", fun = "mean", position = "dodge") +
    labs(title = "Occupation vs Purchase", x = "Occupation", y = "Average Purchase")
  save_plot(p2, "results/figures/eda_occupation_purchase.png", w=11, h=5)
}

if (all(c("marital_status","purchase","gender") %in% names(df_wal))) {
  p3 <- ggplot(df_wal, aes(x = marital_status, y = purchase, fill = gender)) +
    geom_boxplot() +
    labs(title = "Marital Status vs Purchase")
  save_plot(p3, "results/figures/eda_marital_purchase.png")
}

if (all(c("product_category","purchase","age") %in% names(df_wal))) {
  p4 <- ggplot(df_wal, aes(x = product_category, y = purchase, fill = age)) +
    geom_bar(stat = "summary", fun = "mean", position = "dodge") +
    labs(title = "Purchase by Product Category and Age")
  save_plot(p4, "results/figures/eda_product_age.png", w=12, h=5)
}

if (all(c("product_category","purchase","city_category") %in% names(df_wal))) {
  p5 <- ggplot(df_wal, aes(x = product_category, y = purchase, fill = city_category)) +
    geom_bar(stat = "summary", fun = "mean", position = "dodge") +
    labs(title = "Purchase by Product Category & City Category")
  save_plot(p5, "results/figures/eda_product_city.png", w=12, h=5)
}

# Distribution plots
if ("purchase" %in% names(df_wal)) {
  png("results/figures/purchase_hist.png", width = 900, height = 600)
  hist(df_wal$purchase, breaks = 100, main = "Distribution of Purchase Amount")
  dev.off()
  
  png("results/figures/purchase_boxplot.png", width = 900, height = 600)
  boxplot(df_wal$purchase, main = "Boxplot of Purchase")
  dev.off()
  
  # Outlier detection
  Q1 <- quantile(df_wal$purchase, 0.25)
  Q3 <- quantile(df_wal$purchase, 0.75)
  IQRv <- Q3 - Q1
  lower_bound <- Q1 - 1.5 * IQRv
  upper_bound <- Q3 + 1.5 * IQRv
  
  outliers <- df_wal %>% dplyr::filter(purchase < lower_bound | purchase > upper_bound)
  
  percent_outliers <- round((nrow(outliers) / nrow(df_wal)) * 100, 2)
  
  cat("Outlier upper bound:", upper_bound, "\n")
  cat("Outlier lower bound:", lower_bound, "\n")
  cat("Outlier %:", percent_outliers, "\n")
  
  saveRDS(outliers, "data/processed/outliers.rds")
  cat("Saved: data/processed/outliers.rds\n")
}