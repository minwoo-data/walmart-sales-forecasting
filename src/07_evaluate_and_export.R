# src/07_evaluate_and_export.R
source("src/00_setup.R")

# -------------------------
# Helpers
# -------------------------
rmse <- function(y_true, y_pred) sqrt(mean((y_true - y_pred)^2))
mae  <- function(y_true, y_pred) mean(abs(y_true - y_pred))
r2   <- function(y_true, y_pred) {
  rss <- sum((y_true - y_pred)^2)
  tss <- sum((y_true - mean(y_true))^2)
  1 - rss / tss
}

# caret CV 
extract_caret_best <- function(model_obj) {
  res <- model_obj$results
  
  # bestTune
  if (!is.null(model_obj$bestTune)) {
    bt <- model_obj$bestTune
    for (nm in names(bt)) {
      res <- res[res[[nm]] == bt[[nm]], , drop = FALSE]
    }
  }
  
  #
  if (nrow(res) > 1 && "RMSE" %in% colnames(res)) {
    res <- res[which.min(res$RMSE), , drop = FALSE]
  }
  
  data.frame(
    RMSE = if ("RMSE" %in% names(res)) res$RMSE[1] else NA_real_,
    Rsquared = if ("Rsquared" %in% names(res)) res$Rsquared[1] else NA_real_,
    MAE = if ("MAE" %in% names(res)) res$MAE[1] else NA_real_
  )
}

# 
add_row <- function(df, model_name, scale_note, metrics_df, notes = "") {
  rbind(
    df,
    data.frame(
      Model = model_name,
      Scale = scale_note,
      RMSE = metrics_df$RMSE[1],
      Rsquared = metrics_df$Rsquared[1],
      MAE = metrics_df$MAE[1],
      Notes = notes,
      stringsAsFactors = FALSE
    )
  )
}

# -------------------------
# Load processed data
# -------------------------
df_model <- readRDS("data/processed/df_model.rds")
df_model_log <- readRDS("data/processed/df_model_log.rds")

# -------------------------
# Load saved models (if exist)
# -------------------------
model_paths <- list(
  lm_cv       = "outputs/models/lm_cv.rds",
  lm_cv_log   = "outputs/models/lm_cv_log.rds",
  ridge_cv    = "outputs/models/ridge_cv.rds",
  ridge_cv_log= "outputs/models/ridge_cv_log.rds",
  lasso_cv    = "outputs/models/lasso_cv.rds",
  lasso_cv_log= "outputs/models/lasso_cv_log.rds",
  rf_raw      = "outputs/models/rf_raw.rds",
  rf_log      = "outputs/models/rf_log.rds",
  gbm_raw     = "outputs/models/gbm_raw.rds",
  gbm_log     = "outputs/models/gbm_log.rds",
  xgb_cv      = "outputs/models/xgb_cv.rds"
)

models <- list()
for (nm in names(model_paths)) {
  p <- model_paths[[nm]]
  if (file.exists(p)) {
    models[[nm]] <- readRDS(p)
  }
}

# -------------------------
# Build metrics table
# -------------------------
metrics_summary <- data.frame(
  Model = character(),
  Scale = character(),
  RMSE = numeric(),
  Rsquared = numeric(),
  MAE = numeric(),
  Notes = character(),
  stringsAsFactors = FALSE
)

# ---- CV models (raw / log scale)
if (!is.null(models$lm_cv)) {
  m <- extract_caret_best(models$lm_cv)
  metrics_summary <- add_row(metrics_summary, "Linear Regression", "Raw", m, "5-fold CV")
}
if (!is.null(models$lm_cv_log)) {
  m <- extract_caret_best(models$lm_cv_log)
  metrics_summary <- add_row(metrics_summary, "Linear Regression", "Log", m, "5-fold CV (log target)")
}

if (!is.null(models$ridge_cv)) {
  m <- extract_caret_best(models$ridge_cv)
  metrics_summary <- add_row(metrics_summary, "Ridge Regression", "Raw", m, "5-fold CV")
}
if (!is.null(models$ridge_cv_log)) {
  m <- extract_caret_best(models$ridge_cv_log)
  metrics_summary <- add_row(metrics_summary, "Ridge Regression", "Log", m, "5-fold CV (log target)")
}

if (!is.null(models$lasso_cv)) {
  m <- extract_caret_best(models$lasso_cv)
  metrics_summary <- add_row(metrics_summary, "Lasso Regression", "Raw", m, "5-fold CV")
}
if (!is.null(models$lasso_cv_log)) {
  m <- extract_caret_best(models$lasso_cv_log)
  metrics_summary <- add_row(metrics_summary, "Lasso Regression", "Log", m, "5-fold CV (log target)")
}

set.seed(2775)

train_idx_raw <- createDataPartition(df_model$purchase, p = 0.7, list = FALSE)
train_raw <- df_model[train_idx_raw, ]
test_raw <- df_model[-train_idx_raw, ]

train_idx_log <- createDataPartition(df_model_log$log_purchase, p = 0.7, list = FALSE)
train_log <- df_model_log[train_idx_log, ]
test_log <- df_model_log[-train_idx_log, ]

if (!is.null(models$rf_raw)) {
  pred <- predict(models$rf_raw, newdata = test_raw)
  m <- data.frame(
    RMSE = rmse(test_raw$purchase, pred),
    Rsquared = r2(test_raw$purchase, pred),
    MAE = mae(test_raw$purchase, pred)
  )
  metrics_summary <- add_row(metrics_summary, "Random Forest", "Raw", m, "Train/Test split (70/30)")
}

if (!is.null(models$rf_log)) {
  pred_log <- predict(models$rf_log, newdata = test_log)
  pred <- expm1(pred_log)  # log1p inverse
  m <- data.frame(
    RMSE = rmse(test_log$purchase, pred),
    Rsquared = r2(test_log$purchase, pred),
    MAE = mae(test_log$purchase, pred)
  )
  metrics_summary <- add_row(metrics_summary, "Random Forest", "Log→Raw", m, "Train/Test split (70/30), back-transform")
}

if (!is.null(models$gbm_raw)) {
  pred <- predict(models$gbm_raw, newdata = test_raw)
  m <- data.frame(
    RMSE = rmse(test_raw$purchase, pred),
    Rsquared = r2(test_raw$purchase, pred),
    MAE = mae(test_raw$purchase, pred)
  )
  metrics_summary <- add_row(metrics_summary, "GBM", "Raw", m, "Train/Test split (70/30)")
}

if (!is.null(models$gbm_log)) {
  pred_log <- predict(models$gbm_log, newdata = test_log)
  pred <- expm1(pred_log)
  m <- data.frame(
    RMSE = rmse(test_log$purchase, pred),
    Rsquared = r2(test_log$purchase, pred),
    MAE = mae(test_log$purchase, pred)
  )
  metrics_summary <- add_row(metrics_summary, "GBM", "Log→Raw", m, "Train/Test split (70/30), back-transform")
}

# ---- XGBoost
if (!is.null(models$xgb_cv)) {
  m <- extract_caret_best(models$xgb_cv)
  metrics_summary <- add_row(metrics_summary, "XGBoost (xgbTree)", "Raw", m, "5-fold CV")
}

# -------------------------
# Export
# -------------------------
metrics_summary <- metrics_summary %>%
  arrange(desc(Rsquared))

write_csv(metrics_summary, "results/metrics_summary.csv")

cat("\n Exported: results/metrics_summary.csv\n")
print(metrics_summary)
