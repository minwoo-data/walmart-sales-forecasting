# src/00_setup.R
required_packages <- c(
  "tidyverse",     # Data manipulation and visualization
  "ggplot2",       # Data visualization
  "GGally",        # Enhanced ggplot2 functions for pairwise plots
  "skimr",         # Summary statistics
  "caret",         # Machine learning framework for training and tuning
  "glmnet",        # For Ridge and Lasso regression
  "MASS",          # For linear regression and stepwise selection (stepAIC)
  "randomForest",  # For Random Forest model
  "xgboost",       # For Gradient Boosted Trees
  "gbm",           # For Generalized Boosted Models
  "neuralnet",     # For Neural Networks
  "rpart",         # For Decision Trees
  "rpart.plot",     # For plotting Decision Trees
  "car",
  "fastDummies"
)

install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  } else {
    library(pkg, character.only = TRUE)
  }
}

invisible(lapply(required_packages, install_if_missing))

set.seed(2775)

dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
dir.create("results/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/models", recursive = TRUE, showWarnings = FALSE)
