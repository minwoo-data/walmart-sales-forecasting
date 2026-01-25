# src/04_linear_and_regularized_models.R
source("src/00_setup.R")

df_model <- readRDS("data/processed/df_model.rds")
df_model_log <- readRDS("data/processed/df_model_log.rds")

control_5 <- trainControl(method = "cv", number = 5)

# Stepwise (optional)
lm_full <- lm(purchase ~ ., data = df_model)
lm_start <- lm(purchase ~ 1, data = df_model)

stepwise_both <- stepAIC(
  lm_start,
  scope = list(upper = lm_full, lower = lm_start),
  direction = "both",
  trace = TRUE
)

summary(stepwise_both)
vif(stepwise_both)

# Linear CV
lm_cv <- train(purchase ~ ., data = df_model, method = "lm", trControl = control_5)
lm_cv_log <- train(log_purchase ~ . -purchase, data = df_model_log, method = "lm", trControl = control_5)

print(lm_cv)
print(lm_cv_log)

# Ridge/Lasso grids
grid_ridge <- expand.grid(alpha = 0, lambda = 10^seq(3, -3, length = 10))
grid_lasso <- expand.grid(alpha = 1, lambda = 10^seq(3, -3, length = 10))

ridge_cv <- train(purchase ~ ., data = df_model, method = "glmnet", trControl = control_5, tuneGrid = grid_ridge)
ridge_cv_log <- train(log_purchase ~ . -purchase, data = df_model_log, method = "glmnet", trControl = control_5, tuneGrid = grid_ridge)

lasso_cv <- train(purchase ~ ., data = df_model, method = "glmnet", trControl = control_5, tuneGrid = grid_lasso)
lasso_cv_log <- train(log_purchase ~ . -purchase, data = df_model_log, method = "glmnet", trControl = control_5, tuneGrid = grid_lasso)

# Save models
saveRDS(lm_cv, "outputs/models/lm_cv.rds")
saveRDS(lm_cv_log, "outputs/models/lm_cv_log.rds")
saveRDS(ridge_cv, "outputs/models/ridge_cv.rds")
saveRDS(ridge_cv_log, "outputs/models/ridge_cv_log.rds")
saveRDS(lasso_cv, "outputs/models/lasso_cv.rds")
saveRDS(lasso_cv_log, "outputs/models/lasso_cv_log.rds")

cat("Saved linear/ridge/lasso models in outputs/models/\n")
