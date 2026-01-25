# src/05_tree_models.R
source("src/00_setup.R")

df_model <- readRDS("data/processed/df_model.rds")
df_model_log <- readRDS("data/processed/df_model_log.rds")

# Split (raw)
train_idx_raw <- createDataPartition(df_model$purchase, p = 0.7, list = FALSE)
train_raw <- df_model[train_idx_raw, ]
test_raw <- df_model[-train_idx_raw, ]

# Split (log)
train_idx_log <- createDataPartition(df_model_log$log_purchase, p = 0.7, list = FALSE)
train_log <- df_model_log[train_idx_log, ]
test_log <- df_model_log[-train_idx_log, ]

grid_rf2 <- expand.grid(mtry = 2)

# Random Forest raw
rf_raw <- train(
  purchase ~ .,
  data = train_raw,
  method = "rf",
  tuneGrid = grid_rf2,
  trControl = trainControl(method = "none"),
  ntree = 300
)
pred_rf_raw <- predict(rf_raw, newdata = test_raw)
rmse_rf_raw <- sqrt(mean((test_raw$purchase - pred_rf_raw)^2))

# Random Forest log -> raw
rf_log <- train(
  log_purchase ~ . -purchase,
  data = train_log,
  method = "rf",
  tuneGrid = grid_rf2,
  trControl = trainControl(method = "none"),
  ntree = 500
)
pred_rf_log <- predict(rf_log, newdata = test_log)
pred_rf_log_to_raw <- exp(pred_rf_log) - 1
rmse_rf_log <- sqrt(mean((test_log$purchase - pred_rf_log_to_raw)^2))

saveRDS(rf_raw, "outputs/models/rf_raw.rds")
saveRDS(rf_log, "outputs/models/rf_log.rds")

# GBM config
grid_gbm <- expand.grid(
  interaction.depth = 1,
  n.trees = 200,
  shrinkage = 0.1,
  n.minobsinnode = 10
)

# GBM raw
gbm_raw <- train(
  purchase ~ .,
  data = train_raw,
  method = "gbm",
  tuneGrid = grid_gbm,
  trControl = trainControl(method = "none"),
  verbose = FALSE
)
pred_gbm_raw <- predict(gbm_raw, newdata = test_raw)
rmse_gbm_raw <- sqrt(mean((test_raw$purchase - pred_gbm_raw)^2))

# GBM log -> raw
gbm_log <- train(
  log_purchase ~ . -purchase,
  data = train_log,
  method = "gbm",
  tuneGrid = grid_gbm,
  trControl = trainControl(method = "none"),
  verbose = FALSE
)
pred_gbm_log <- predict(gbm_log, newdata = test_log)
pred_gbm_log_to_raw <- exp(pred_gbm_log) - 1
rmse_gbm_log <- sqrt(mean((test_log$purchase - pred_gbm_log_to_raw)^2))

saveRDS(gbm_raw, "outputs/models/gbm_raw.rds")
saveRDS(gbm_log, "outputs/models/gbm_log.rds")

cat("RMSE RF raw:", rmse_rf_raw, "\n")
cat("RMSE RF log->raw:", rmse_rf_log, "\n")
cat("RMSE GBM raw:", rmse_gbm_raw, "\n")
cat("RMSE GBM log->raw:", rmse_gbm_log, "\n")
