rm(list=ls())

setwd("directory_path")
library("data.table")
library("ggplot2")
library("psych")
library(dplyr)
library(Hmisc)

bank = fread(file = "bank_cleaned.csv",
             na.strings = c("NA", ""), 
             sep = "auto",
             stringsAsFactors = FALSE,
             data.table = TRUE
)

head(bank)
str(bank)
describe(bank)

#drop poutcome
is.data.table(bank) == TRUE
bank <- select(bank, -poutcome)
head(bank)
#######################################################################################

unknown_percentages_in_rows <- (bank == "unknown") * 100
unknown_percentages_in_rows <- rowMeans(unknown_percentages_in_rows)  # Calculate row means

# Define a threshold (optional, adjust as needed)
threshold <- 50  # Rows with more than 50% unknowns will be removed

# Filter rows based on the threshold
filtered_bank <- bank[unknown_percentages_in_rows < threshold, ]

# Print message
cat("Original dataset size:", nrow(bank), "\n")
cat("Filtered dataset size (rows with less than", threshold, "% unknowns):", nrow(filtered_bank), "\n")

# Optional: View the difference
# View(bank)  # View the original data (uncomment if desired)
#View(filtered_bank)
str(filtered_bank)

nrow(filtered_bank)

#40841
###########################################################################################



#job
job_categories <- c("admin.", "bluecollar", "entrepreneur", "housemaid", "management", "other", "retired", "selfemployed", "services", "student", "technician", "unemployed")

for (job_category in job_categories) {
  filtered_bank[job == job_category, paste0("job.", job_category) := 1]
  filtered_bank[job != job_category, paste0("job.", job_category) := 0]
}


#marriage
marriage <- c("married","single","divorced")


for (status in marriage) {
  filtered_bank[marital == status, paste0("marital.", status) := 1]
  filtered_bank[marital != status, paste0("marital.", status) := 0]
}

#education
education <- c("primary","secondary","tertiary")


for (degree in education) {
  filtered_bank[education == degree, paste0("education.", status) := 1]
  filtered_bank[education != degree, paste0("education.", status) := 0]
}


#default and loan
binomial <- c("yes","no")
for (i in binomial) {
  filtered_bank[default == i, paste0("default.", i) := 1]
  filtered_bank[default != i, paste0("default.", i) := 0]
  filtered_bank[loan == i, paste0("loan.", i) := 1]
  filtered_bank[loan != i, paste0("loan.", i) := 0]
  filtered_bank[housing == i, paste0("housing.", i) := 1]
  filtered_bank[housing != i, paste0("housing.", i) := 0]
}



# month
months <- c("jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec")
for (mon in months) {
  filtered_bank[month == mon, paste0("month.", mon) := 1]
  filtered_bank[month != mon, paste0("month.", mon) := 0]
}
head(filtered_bank)
#View(filtered_bank)



#install.packages("randomForest")
library(randomForest)
x <- select(filtered_bank,-c(response,response_binary))
y<- filtered_bank$response_binary
head(x)
head(y)

set.seed(42)
#install.packages("caret")
library(caret)

# Perform train-test split
split_index <- createDataPartition(y, p = 0.6, list = FALSE)
x_train <- x[split_index, ]
x_test <- x[-split_index, ]
y_train <- y[split_index]
y_test <- y[-split_index]
levels(y_test) <- levels(y_train)

# Construct Random Forest classifier
rf_model <- randomForest(y_train ~ ., data = cbind(x_train, y_train),ntree=500)

# Print summary of the Random Forest model
print(rf_model)
#######################################################
predicted_probabilities <- predict(rf_model, newdata = x_test, type = "response")
predicted_classes <- ifelse(predicted_probabilities >= 0.5, 1, 0)


# Calculate accuracy
accuracy <- mean(predicted_classes == y_test)
print(paste("Accuracy:", accuracy))

# Calculate F1-score
#f1_score <- F1_Score(y_test, predicted_classes)
#print(paste("F1-score:", f1_score))

# Create confusion matrix

actual <- y_test
predict <- predicted_classes
cm <- table(predict, actual)
cm


# Calculate confusion matrix
conf_matrix <- confusionMatrix(as.factor(predicted_classes), as.factor(y_test))

# Calculate precision, recall, and F1-score for each class
precision <- conf_matrix$byClass["Pos Pred Value"]
precision
recall <- conf_matrix$byClass["Sensitivity"]
recall
f1_score <- 2 * (precision * recall) / (precision + recall)
f1_score
######################################################################################################
# Calculate macro and weighted averages
macro_avg_precision <- mean(conf_matrix$byClass["Pos Pred Value"])
macro_avg_recall <- mean(conf_matrix$byClass["Sensitivity"])
macro_avg_f1_score <- 2 * (macro_avg_precision * macro_avg_recall) / (macro_avg_precision + macro_avg_recall)

weighted_avg_precision <- sum(conf_matrix$byClass["Pos Pred Value"] * conf_matrix$table[, 1] / sum(conf_matrix$table[,1]))

# Calculate weighted average recall
weighted_avg_recall <- sum(conf_matrix$byClass["Sensitivity"] * conf_matrix$table[, 1] / sum(conf_matrix$table[, 1]))

# Calculate weighted average F1-score
weighted_avg_f1_score <- 2 * (weighted_avg_precision * weighted_avg_recall) / (weighted_avg_precision + weighted_avg_recall)

# Print weighted average precision, recall, and F1-score
print(paste("Weighted Average Precision:", weighted_avg_precision))
print(paste("Weighted Average Recall:", weighted_avg_recall))
print(paste("Weighted Average F1-score:", weighted_avg_f1_score))

#######################################################################################################################
conf_df <- as.data.frame(as.table(conf_matrix))
row_headings <- rownames(cm)
col_headings <- colnames(cm)

# Check if headings are missing
if (is.null(row_headings)) {
  row_headings <- paste("Values", 1:nrow(cm), sep = "")
}
if (is.null(col_headings)) {
  col_headings <- paste("Values", 1:ncol(cm), sep = "")
}

# Convert matrix to data frame
df_cm <- data.frame(Reference = row_headings, Prediction = col_headings)

# Fill the data frame with values from the confusion matrix
df_cm$value <- cm

# Plot the confusion matrix using ggplot (same code as before)
library(ggplot2)


TrueClass <- factor(c(0, 0, 1, 1))
PredictedClass <- factor(c(0, 1, 0, 1))
Y      <- c(13893, 566, 825,1052)
df1 <- data.frame(TrueClass, PredictedClass, Y)

ggplot(df1, mapping = aes(x = TrueClass, y = PredictedClass)) +
  geom_tile(aes(fill = Y), colour = "white") +
  geom_text(aes(label = sprintf("%1.0f", Y)), vjust = 1) +
  scale_fill_gradient(low = "darkslategray4", high = "coral") +
  theme_bw() + theme(legend.position = "top-right")

