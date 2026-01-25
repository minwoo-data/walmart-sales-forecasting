# src/06_optional_xgb_and_nn.R
source("src/00_setup.R")

df_model <- readRDS("data/processed/df_model.rds")

control_5 <- trainControl(method = "cv", number = 5)

grid_xgb <- expand.grid(
  nrounds = 100,
  eta = 0.1,
  max_depth = 3,
  gamma = 0,
  colsample_bytree = 1,
  min_child_weight = 1,
  subsample = 1
)

xgb_cv <- train(
  purchase ~ .,
  data = df_model,
  method = "xgbTree",
  tuneGrid = grid_xgb,
  trControl = control_5,
  verbose = FALSE
)

saveRDS(xgb_cv, "outputs/models/xgb_cv.rds")
print(xgb_cv$results)
