
library(dplyr)
library(mice)
library(ggplot2)
library(caret)
library(e1071)
library(bayesplot)
library(coda)
library(Rcpp)
library(rstanarm)
library(randomForest)
library(mlbench)  


data(HouseVotes84, package = "mlbench")
names(HouseVotes84)
summary(HouseVotes84)
nrow(HouseVotes84)

#Imputazione dei dati mancanti
Hv1 <- data.frame(imputed_pmm = complete(mice(HouseVotes84, method = "pmm")))
Hv_final = Hv1

#Suddivisione in dati di training e testing
set.seed(42)
s <- sample(nrow(Hv_final), nrow(Hv_final) * 0.8)
vote_training = Hv_final[s,]
vote_testing = Hv_final[-s,]

########Log reg baesiana########
bayes_model <- stan_glm(imputed_pmm.Class ~ ., data = vote_training, family = binomial(link = "logit"))  #by defaul 4 mcmc
posterior <- as.array(bayes_model)

# Rhat
rhat_values <- rhat(bayes_model)
print(rhat_values)
#Mcmc trace
mcmc_trace(posterior)
#Waic
#Note that the WAIC model comparison functionality was implemented with reference to both Gelman et al (2013) and McElreath (2016).
rstanarm::waic(bayes_model)
# Significatività dei coefficienti
summary(bayes_model)

####Predictions and furter valuetion for first model
# Make predictions on the testing data
predicted_prob <- posterior_epred(bayes_model, newdata = vote_testing)
# Calculate the mean of the posterior predictions to get the probability
mean_predicted_prob <- colMeans(predicted_prob)
# Assign classes
predicted_class <- ifelse(mean_predicted_prob > 0.5, "republican", "democrat")
actual_class <- vote_testing$imputed_pmm.Class
# Confusion matrix
conf_matrix <- confusionMatrix(factor(predicted_class), factor(actual_class))
print(conf_matrix)
# Precision, recall, and F1 score
precision <- conf_matrix$byClass["Pos Pred Value"]
recall <- conf_matrix$byClass["Sensitivity"]
f1_score <- 2 * (precision * recall) / (precision + recall)
cat("Precision: ", precision, "\n")
cat("Recall: ", recall, "\n")
cat("F1 Score: ", f1_score, "\n")

########Log reg baesiana con variabili selezionate########
vote_training_filtered <- vote_training %>%
  select(-c(2, 3, 6, 7, 8, 9, 10, 14, 15, 17))
vote_testing_filtered <- vote_testing %>%
  select(-c(2, 3, 6, 7, 8, 9, 10, 14, 15, 17))

bayes_model2 <- stan_glm(imputed_pmm.Class ~ ., data = vote_training_filtered, family = binomial(link = "logit"))
posterior2 <- as.array(bayes_model2)


# Rhat
rhat_values2 <- rhat(bayes_model2)
print(rhat_values2)
#Mcmc trace
mcmc_trace(posterior2)
#Waic
rstanarm::waic(bayes_model2)
# Significatività dei coefficienti
summary(bayes_model2)
#########Predictions and further valutation for second model###########
# Make predictions on the testing data
predicted_prob2 <- posterior_epred(bayes_model2, newdata = vote_testing_filtered)
# Take the mean of the posterior predictions to get the probability
mean_predicted_prob2 <- colMeans(predicted_prob2)
# Assign classes 
predicted_class2 <- ifelse(mean_predicted_prob2 > 0.5, "republican", "democrat")
actual_class2 <- vote_testing_filtered$imputed_pmm.Class
# Confusion matrix
conf_matrix2 <- confusionMatrix(factor(predicted_class2), factor(actual_class2))
print(conf_matrix2)
# Precision, recall, and F1 score
precision2 <- conf_matrix2$byClass["Pos Pred Value"]
recall2 <- conf_matrix2$byClass["Sensitivity"]
f1_score2 <- 2 * (precision2 * recall2) / (precision2 + recall2)
cat("Precision: ", precision2, "\n")
cat("Recall: ", recall2, "\n")
cat("F1 Score: ", f1_score2, "\n")

######## Modello Naive Bayes con Laplace smoothing #########
nb2 <- naiveBayes(imputed_pmm.Class ~ ., data = vote_training, laplace = 1)
nbfinal = nb2
# Previsioni
predict1 <- predict(nbfinal, vote_testing[,-1])
confusion_matrix3 <- table(predict1, vote_testing$imputed_pmm.Class)
print(confusion_matrix3)

#########Model with Random Tree feature selection#######
####Importance definition
# Random forest model to determine feature importance
rf_model <- randomForest(imputed_pmm.Class ~ ., data = vote_training, importance = TRUE)
# Get feature importance
importance_scores <- importance(rf_model)
# Sort features by importance
sorted_importance <- sort(importance_scores[, 1], decreasing = TRUE)
# Select top N important features
top_n_features <- names(sorted_importance)[1:15]
# Print top N important features
print(top_n_features)

# Subset data to include only the top N features
vote_training_selected <- vote_training %>%
  select(imputed_pmm.Class, all_of(top_n_features))
vote_testing_selected <- vote_testing %>%
  select(imputed_pmm.Class, all_of(top_n_features))
#####Model
# Bayesian logistic regression model with selected features
bayes_model_selected <- stan_glm(imputed_pmm.Class ~ ., data = vote_training_selected, family = binomial(link = "logit"))
posterior_selected <- as.array(bayes_model_selected)

# Rhat
rhat_values_selected <- rhat(bayes_model_selected)
print(rhat_values_selected)
#Mcmc trace
mcmc_trace(posterior_selected)
#Waic
rstanarm::waic(bayes_model_selected)
# Significatività dei coefficienti
summary(bayes_model_selected)


##### Predictions
predicted_prob_selected <- posterior_epred(bayes_model_selected, newdata = vote_testing_selected)
# Calculate the mean of the posterior predictions
mean_predicted_prob_selected <- colMeans(predicted_prob_selected)
predicted_class_selected <- ifelse(mean_predicted_prob_selected > 0.5, "republican", "democrat")
# Create a confusion matrix
actual_class_selected <- vote_testing_selected$imputed_pmm.Class
conf_matrix_selected <- confusionMatrix(factor(predicted_class_selected), factor(actual_class_selected))
print(conf_matrix_selected)

# Precision, recall, and F1 score
precision_selected <- conf_matrix_selected$byClass["Pos Pred Value"]
recall_selected <- conf_matrix_selected$byClass["Sensitivity"]
f1_score_selected <- 2 * (precision_selected * recall_selected) / (precision_selected + recall_selected)
cat("Precision: ", precision_selected, "\n")
cat("Recall: ", recall_selected, "\n")
cat("F1 Score: ", f1_score_selected, "\n")




